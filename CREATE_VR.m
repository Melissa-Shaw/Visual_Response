%% Script to create and save VR mat file with responses to all visual stimuli.
% Output:
    % VR struct:
        % VR.spike_raster --> spike raster
        % VR.clusteridx --> array of cluster ID for each unit
        % VR.channel --> array of probe channel for each unit
        % VR.units --> logical array of units to be included
        % VR.cond_timepoints --> condition timepoints in ms
        % VR.location --> cell array of probe location for each unit
        % VR.COI --> cell array of conditions of interest
        % VR.M_baseFR --> mean baseline FR for each unit
        % VR.nat --> struct with natural images details and responses
        % VR.grat --> struct with visual grating details and responses
        % VR.rec_map --> struct with receptive mapping details and LFP response
        % VR.LFP --> struct with 2 outputs of LFP power at given frequency
                     % and the frequency bounds chosen
        % VR.neuronFR --> firing rates of each neuron x each second
        % VR.popFR --> population firing rate each second
        % VR.RF --> stimulus triggered LFP in response to receptive mapping
    

function [VR] = create_VR(db,exp,find_rec_resp,save_VR)
    % Set up
    shared_drive = 'X:';
    addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\General']);
    addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\LFP_Analysis']);
    addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\Spike_Analysis']); % calc_running_sum
    addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\Psychopy']);
    addpath([shared_drive '\cortical_dynamics\Shared\Code\matlib\IO\']);

    % set parameters
    params.binsize = 5; % 1ms bins for psth - only use common factor of all buffer stim lengths
    params.sig_threshold = 0.01; % threshold of significance (p-value)
    params.iCh = 3; % channel index for spikestruct LFP - NEED REASONING FOR CHOICE
    params.region = 'V1'; % probe region
    params.is_dual = false;
    params.freq_bounds = [8 32]; % frequency bounds for LFP power 
    params.smth = 250; % smoothing factor for population rate and LFP (250 seconds)
    params.cond_names = {'baselinepre','ViStimpre_grating','ViStimpre','ViStimpost_grating','ViStimpost'}; % conditions of interest (COI)

    % load spikestruct
    disp(['Exp: ' num2str(exp)]);
    [spikestruct] = load_spikestruct(shared_drive,db,exp);
    disp('Spikestruct loaded');

    % extract spikestruct data
    if strcmp(db(exp).animal,'M220613_B_MS')
        VR.units = spikestruct.depth >= 2000; % units in top 1mm only for NP1 recordings
    else
        VR.units = spikestruct.depth >= 0; % all units
    end
    VR.binsize = params.binsize;
    VR.sig_threshold = params.sig_threshold;
    VR.spike_raster = spikestruct.raster(VR.units,:);
    VR.clusteridx = spikestruct.clusteridx(VR.units);
    VR.channel = spikestruct.channel(VR.units);
    VR.cond_timepoints = spikestruct.timepoints; % timepoints in ms
    VR.cond_timepoints(1) = 1; % correct index for rounding error

    % Find channel locations
    if strcmp(db(exp).probe,'NP24')
        [VR.location] = map_channel_to_location(VR.channel);
    else
        VR.location = NaN(numel(VR.channel),1); % if NP1 probe then don't need location - MAYBE ADD DEPTH INSTEAD?
    end

    % Find conditions of interest (COI)
    VR.COI = params.cond_names;
    for vis_cond = 1:numel(params.cond_names)
        VR.COI{2,vis_cond} = NaN;
        for c = 1:numel(db(exp).injection)
            if strcmp(db(exp).injection{c},params.cond_names{vis_cond})
                VR.COI{2,vis_cond} = c;
            end
        end
    end
    clear vis_cond c 
    base_cond = VR.COI{2,1};
    grat_cond = [VR.COI{2,2} VR.COI{2,4}];
    nat_cond = [VR.COI{2,3} VR.COI{2,5}];

    % Find mean baseline firing rate for each neuron
    VR.M_baseFR = mean(VR.spike_raster(:,VR.cond_timepoints(base_cond):VR.cond_timepoints(base_cond+1)),2)*1000;  % mean baselineFR in spikes/s

    % Extract stim parameters with frametimes
    [VR.nat,VR.grat,VR.rec_map] = extract_ViStim_parameters(spikestruct,grat_cond,nat_cond,params.binsize);
    clear grat_cond nat_cond

    % Get LFP
    disp('Creating LFP...');
    [indvLFP] = create_LFP_struct(db(exp),spikestruct,params);
    [VR.LFP.freq_power] = freq_filter_LFP(indvLFP,params.freq_bounds,base_cond);
    VR.LFP.freq_bounds = params.freq_bounds;
    clear indvLFP base_cond

    % Find firing rates for neurons and population
    VR.neuronFR = NaN(sum(VR.units),VR.cond_timepoints(end)/1000);
    for n = 1:sum(VR.units)
        VR.neuronFR(n,:) = calc_running_sum(VR.spike_raster(n,:),1000); % bin of 1000ms for sp/s
    end
    VR.popFR = sum(VR.neuronFR);
    clear n

    % Get receptive field response
    if find_rec_resp == true
        disp('Creating RF...');
        [VR.RF] = find_rec_map_response(VR.rec_map,db(exp));
        disp('RF created');
    end

    % Find psth, sig_responses and response amplitudes for visual responses
    disp('Finding responses...');
    [VR.nat] = process_visual_responses(VR.spike_raster,VR.nat,params);
    [VR.grat] = process_visual_responses(VR.spike_raster,VR.grat,params);
    
    % Find stimtype units with sig response pre and post
    %VR.nat.sig_units.type{1} = VR.nat.sig_response(1).type{1} | VR.nat.sig_response(2).type{1};
    %VR.sig_units.class = VR.grat.sig_response(1).type{1} | VR.grat.sig_response(2).type{1};
    %VR.sig_units.inv = VR.grat.sig_response(1).type{2} | VR.grat.sig_response(2).type{2};
    %VR.sig_units.ff = VR.grat.sig_response(1).type{3} | VR.grat.sig_response(2).type{3};

    % Save VR
    if save_VR == true
        disp('Saving VR...');
        save([shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Exp_' num2str(exp) '_' db(exp).animal '_' db(exp).date '\VR.mat'],'VR','-v7.3');
        disp('VR saved');
        clear VR
    end


    %% LOCAL Functions
    function [ViStim] = process_visual_responses(spike_raster,ViStim,params)
        buffer_bin = ViStim.buffer/params.binsize;
        stim_bin = ViStim.stim/params.binsize;
        for p = 1:2 % for each condition
            for t = 1:numel(ViStim.stimtype) % for each type of stimulus (class/inv/fullfield)
                [ViStim.spiketimes(p).type{t}] = find_spiketimes(spike_raster,ViStim.frametimes{p}(ViStim.trials{t}),ViStim.buffer,ViStim.stim);
                [ViStim.psth(p).type{t},ViStim.psth_SEM(p).type{t}] = find_psth(ViStim.spiketimes(p).type{t},ViStim.frametimes{p}(ViStim.trials{t}),ViStim.edges);
                [~,ViStim.sig_response(p).type{t}] = find_sig_neurons(ViStim.psth(p).type{t},ViStim.buffer,ViStim.stim,params.binsize,params.sig_threshold);
                ViStim.evoked(p).type{t} = mean(ViStim.psth(p).type{t}(:,buffer_bin+1:buffer_bin+stim_bin),2);
                ViStim.spont(p).type{t} = mean(ViStim.psth(p).type{t}(:,1:buffer_bin),2);
                ViStim.resp(p).type{t} = ViStim.evoked(p).type{t}./ViStim.spont(p).type{t};
                
                for d = 1:numel(ViStim.directions) % for each direction
                    [ViStim.spiketimes(p).type_dir{d,t}] = find_spiketimes(spike_raster,ViStim.frametimes{p}(ViStim.trials{t} & ViStim.direct_trials{d}),ViStim.buffer,ViStim.stim);
                    [ViStim.psth(p).type_dir{d,t},ViStim.psth_SEM(p).type_dir{d,t}] = find_psth(ViStim.spiketimes(p).type_dir{d,t},ViStim.frametimes{p}(ViStim.trials{t} & ViStim.direct_trials{d}),ViStim.edges);
                    [~,ViStim.sig_response(p).type_dir{d,t}] = find_sig_neurons(ViStim.psth(p).type_dir{d,t},ViStim.buffer,ViStim.stim,params.binsize,params.sig_threshold);
                    ViStim.evoked(p).type_dir{d,t} = mean(ViStim.psth(p).type_dir{d,t}(:,buffer_bin+1:buffer_bin+stim_bin),2);
                    ViStim.spont(p).type_dir{d,t} = mean(ViStim.psth(p).type_dir{d,t}(:,1:buffer_bin),2);
                    ViStim.resp(p).type_dir{d,t} = ViStim.evoked(p).type_dir{d,t}./ViStim.spont(p).type_dir{d,t};
                    ViStim.resp(p).type_dir{d,t}(ViStim.resp(p).type_dir{d,t}==Inf | ViStim.resp(p).type_dir{d,t}==-Inf) = NaN;
                    
                    trials = find(ViStim.trials{t} & ViStim.direct_trials{d});
                    for tr = 1:numel(trials)
                       [ViStim.psth(p).type_dir_trial{d,t}(:,tr),~] = find_psth(ViStim.spiketimes(p).type_dir{d,t}(:,tr),ViStim.frametimes{p}(trials(tr)),ViStim.edges);
                       for n = 1:size(spike_raster,1)
                         [~,ViStim.sig_response(p).type_dir_trial{d,t}(n,tr)] = find_sig_neurons(ViStim.psth(p).type_dir_trial{d,t}{n,tr},ViStim.buffer,ViStim.stim,params.binsize,params.sig_threshold);
                         ViStim.evoked(p).type_dir_trial{d,t}(n,tr) = mean(ViStim.psth(p).type_dir_trial{d,t}{n,tr}(buffer_bin+1:buffer_bin+stim_bin));
                         ViStim.spont(p).type_dir_trial{d,t}(n,tr) = mean(ViStim.psth(p).type_dir_trial{d,t}{n,tr}(1:buffer_bin));
                       end
                    end
                   ViStim.resp(p).type_dir_trial{d,t} = ViStim.evoked(p).type_dir_trial{d,t}./ViStim.spont(p).type_dir_trial{d,t};
                   ViStim.resp(p).type_dir_trial{d,t}(ViStim.resp(p).type_dir_trial{d,t}==Inf | ViStim.resp(p).type_dir_trial{d,t}==-Inf) = NaN;
                end
            end
        end
        for t = 1:numel(ViStim.stimtype) % for each stimtype
            ViStim.sig_units.type{t} = ViStim.sig_response(1).type{t} | ViStim.sig_response(2).type{t};
        end
    end

    function [location] = map_channel_to_location(channel)
        location = cell(numel(channel),1);
        for n = 1:numel(channel) % for each unit
            if channel(n) <= 48
                location{n} = 'shank_1_deep';
            elseif channel(n) >= 97 & channel(n) <= 144
                location{n} = 'shank_1_shallow';
            elseif channel(n) >= 49 & channel(n) <= 96
                location{n} = 'shank_2_deep';
            elseif channel(n) >= 145 & channel(n) <= 192
                location{n} = 'shank_2_shallow';
            elseif channel(n) >= 193 & channel(n) <= 240
                location{n} = 'shank_3_deep';
            elseif VR.channel(n) >= 289 & channel(n) <= 336
                location{n} = 'shank_3_shallow';
            elseif channel(n) >= 241 & channel(n) <= 288
                location{n} = 'shank_4_deep';
            elseif channel(n) >= 337 & channel(n) <= 384
                location{n} = 'shank_4_shallow';
            end
        end
    end

end
