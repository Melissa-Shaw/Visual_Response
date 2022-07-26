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
    

%% Set up
shared_drive = 'X:';
addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\General']);
addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\LFP_Analysis']);
addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\Spike_Analysis']); % calc_running_sum
addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\Psychopy']);
addpath([shared_drive '\cortical_dynamics\Shared\Code\matlib\IO\']);

% load db struct
run('makedb_TCB2_MS'); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% set parameters
params.binsize = 1; % 100ms bins for psth
params.sig_threshold = 0.05; % threshold of significance (p-value)
params.iCh = 3; % channel index for spikestruct LFP - NEED REASONING FOR CHOICE
params.region = 'V1'; % probe region
params.is_dual = false;
params.freq_bounds = [8 32]; % frequency bounds for LFP power 
params.smth = 250; % smoothing factor for population rate and LFP (250 seconds)
params.cond_names = {'baselinepre','ViStimpre_grating','ViStimpre','ViStimpost_grating','ViStimpost'}; % conditions of interest (COI)

% set script options - TEMP MEASURE TO MAKE SCRIPT FLEXIBLE WHILE CODING
opt.find_rec_resp = true; % find receptive mapping response (slow to run)
opt.save_VR = true; % save visual response (VR) mat file
opt.plot_summary_fig = true;
opt.save_figures = true; % save summary figures

% load spikestruct
i = 1; % set exp count
for exp = [AnaesV1 AwakeV1]
    disp(['Exp: ' num2str(exp)]);
    [spikestruct] = load_spikestruct(shared_drive,db,exp);
    disp('Spikestruct loaded');

    %% Create VR struct
    if strcmp(db(exp).animal,'M220613_B_MS')
        VR.units = spikestruct.depth >= 2000; % units in top 1mm only for NP1 recordings
    else
        VR.units = spikestruct.depth >= 0; % all units
    end
    VR.spike_raster = spikestruct.raster(VR.units,:);
    VR.clusteridx = spikestruct.clusteridx(VR.units);
    VR.channel = spikestruct.channel(VR.units);
    VR.cond_timepoints = spikestruct.timepoints; % timepoints in ms
    VR.cond_timepoints(1) = 1; % correct index for rounding error
    
    % Find channel locations
    VR.location = cell(numel(VR.channel),1);
    for n = 1:numel(VR.channel) % for each unit
        if strcmp(db(exp).probe,'NP1')
            VR.location{n} = NaN; % if NP1 probe then don't need location - MAYBE ADD DEPTH INSTEAD?
        elseif VR.channel(n) >= 1 & VR.channel(n) <= 48
            VR.location{n} = 'shank_1_deep';
        elseif VR.channel(n) >= 97 & VR.channel(n) <= 144
            VR.location{n} = 'shank_1_shallow';
        elseif VR.channel(n) >= 49 & VR.channel(n) <= 96
            VR.location{n} = 'shank_2_deep';
        elseif VR.channel(n) >= 145 & VR.channel(n) <= 192
            VR.location{n} = 'shank_2_shallow';
        elseif VR.channel(n) >= 193 & VR.channel(n) <= 240
            VR.location{n} = 'shank_3_deep';
        elseif VR.channel(n) >= 289 & VR.channel(n) <= 336
            VR.location{n} = 'shank_3_shallow';
        elseif VR.channel(n) >= 241 & VR.channel(n) <= 288
            VR.location{n} = 'shank_4_deep';
        elseif VR.channel(n) >= 337 & VR.channel(n) <= 384
            VR.location{n} = 'shank_4_shallow';
        end
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
    if opt.find_rec_resp == true
        disp('Creating RF...');
        [VR.RF] = find_rec_map_response(VR.rec_map,db(exp));
        disp('RF created');
    end
    
    % Find psth for visual responses
    % Nat Stim
    for p = 1:numel(VR.nat.frametimes) % for each presentation of natural images stimuli (pre/post)
        [VR.nat.spiketimes{p}] = find_spiketimes(VR.spike_raster,VR.nat.frametimes{p},VR.nat.buffer,VR.nat.stim);
        [VR.nat.psth{p},VR.nat.psth_SEM{p}] = find_psth(VR.nat.spiketimes{p},VR.nat.frametimes{p},VR.nat.edges,VR.M_baseFR);
        [~,VR.nat.sig_response{p}(:,1)] = find_sig_neurons(VR.nat.psth{p},VR.nat.buffer,VR.nat.stim,params.binsize,params.sig_threshold);
    end
    % Grat Stim
    for p = 1:numel(VR.grat.frametimes) % for each presentation of grating stimuli (pre/post)
        for t = 1:numel(VR.grat.stimtype) % for each type of stimulus (class/inv/fullfield)
            [VR.grat.spiketimes{p}{t}] = find_spiketimes(VR.spike_raster,VR.grat.frametimes{p}(VR.grat.trials{t}),VR.grat.buffer,VR.grat.stim);
            [VR.grat.psth{p}{t},VR.grat.psth_SEM{p}{t}] = find_psth(VR.grat.spiketimes{p}{t},VR.grat.frametimes{p}(VR.grat.trials{t}),VR.grat.edges,VR.M_baseFR);
            [~,VR.grat.sig_response{p}(:,t)] = find_sig_neurons(VR.grat.psth{p}{t},VR.grat.buffer,VR.grat.stim,params.binsize,params.sig_threshold);
        end
    end
    clear p
    
    if opt.save_VR == true
        disp('Saving VR...');
        save([shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Exp_' num2str(exp) '_' db(exp).animal '_' db(exp).date '\VR.mat'],'VR','-v7.3');
        disp('VR saved');
    end
    
    %% Create summary figure
    % Plot summary figure
    if opt.plot_summary_fig == true
        plot_summary_figure(db(exp),exp,VR,params.smth);
    end
    
    % Save summary figure
    if opt.save_figures == true
        disp('Saving summary figure...');
        savefig([shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_Summary.fig']);
        disp('Summary figure saved');
    end

    %% Add exp VR to group
    VR_all(i) = VR;
    i = i+1;
end

VR = VR_all; clear VR_all

