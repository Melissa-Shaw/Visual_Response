% Function to create structs which hold the parameters of the different
% visual stimulation given.
    % Inputs: 
        % grat_cond --> 2 number array with condition index for pre and post visual grating conditions
        % nat_cond --> 2 number array with condition index for pre and post natural images conditions
        % binsize --> binsize for psth analysis in ms
    % Outputs:
        % nat --> struct with details and frametimes for natural images
        % grat --> struct with details and frametimes for visual grating
        % rec_map --> struct with details and frametimes for receptive mapping

function [nat,grat,rec_map] = extract_ViStim_parameters(spikestruct,grat_cond,nat_cond,binsize)

    % set up natural images parameters
    [~,ID_order] = sort(spikestruct.ViStimID_natural);
    nat.cond = nat_cond; 
    nat.frametimes = {spikestruct.frameTimes{nat_cond(1)}(ID_order) spikestruct.frameTimes{nat_cond(2)}(ID_order)};
    nat.colour = {'g'};
    nat.marker = {'x'};
    nat.buffer = 1500;
    nat.stim = 750;
    nat.num_repeats = 6;
    nat.stimtype = {'nat'};
    nat.trials = {spikestruct.ViStimID_natural > 0}; % all stim for nat images
    nat.directions = 1;
    nat.direct_trials = {1};
    nat.edges = [-nat.buffer:binsize:nat.stim+nat.buffer];
    
    % set up grating stim parameters
    [~,ID_order_1] = sort(spikestruct.ViStimID_grating{1}); % sort by ID order
    [~,ID_order_2] = sort(spikestruct.ViStimID_grating{2});
    grat.cond = grat_cond;
    grat.det = sortrows(spikestruct.ViStimDetails_grating,2); % sort by stimtype then direction
    grat.frametimes = {spikestruct.frameTimes{grat_cond(1)}(ID_order_1) spikestruct.frameTimes{grat_cond(2)}(ID_order_2)}; % sort by ID order
    grat.frametimes = {grat.frametimes{1}(grat.det(:,1)) grat.frametimes{2}(grat.det(:,1))}; % sort by stimtype and direction
    grat.colour = {'k','r','b'};
    grat.marker = {'o' '+' '.'};
    grat.buffer = 1500;
    grat.stim = 1000;
    grat.num_repeats = 10;
    grat.num_frames_stimtype = 8*grat.num_repeats; % 80 frames of each stimtype
    grat.stimtype = {'class' 'inv' 'ff'}; % class, inv, ff
    grat.trials = {grat.det(:,3) == 1, grat.det(:,3) == 2, grat.det(:,3) == 3};
    grat.directions = unique(grat.det(:,4))';
    grat.direct_trials = {grat.det(:,4) == 0, grat.det(:,4) == 45, grat.det(:,4) == 90, grat.det(:,4) == 135, grat.det(:,4) == 180,...
        grat.det(:,4) == 225, grat.det(:,4) == 270, grat.det(:,4) == 315};
    grat.edges = [-grat.buffer:binsize:grat.stim+grat.buffer];
    
    % set up receptive mapping stim parameters
    rec_map.det = spikestruct.RecMapStimDetails;
    rec_map.det(rec_map.det(:,2) == 2,[3 6]) = NaN;
    rec_map.det(rec_map.det(:,2) == 1,[4 7]) = NaN;
    rec_map.ID = spikestruct.RecMapStimID;
    rec_map.frametimes = spikestruct.RecMap_frameTimes;
    rec_map.buffer = 1500;
    rec_map.stim = 1000;
    rec_map.stimtype = {'horz' 'vert'}; % horizontal position (vertical stripes) and vertical position (horizontal stripes)
    rec_map.coords = spikestruct.RecField(1:2);
    rec_map.lfpchan = spikestruct.RecField(3);
    rec_map.edges = [-rec_map.buffer:rec_map.buffer+rec_map.stim-1];

end

