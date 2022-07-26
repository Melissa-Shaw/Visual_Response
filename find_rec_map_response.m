% Function to find stimulus triggered LFP response to receptive mapping at
% chosen lfp channel to illustrate reasoning for receptive field location
% choice during recording.
    % Inputs:
        % rec_map --> struct with details of receptive mapping stimulation (see extract_ViStim_paramters.m)
        % db --> singular db(exp) input with experiment details (see makedb_TCB2_MS.m)
    % Outputs:
        % RF.allstim_response --> stimulus triggered LFP response to all stim over buffer-stim-buffer time period
        % RF.coord_response --> cell array with stimulus triggered LFP response to x-coord stim and y-coord stim over 
                                % buffer-stim-buffer time period

function [RF] = find_rec_map_response(rec_map,db)

    % Extract useful parameters
    totalchans = 385;
    LFPfile = db.rec_map_files{1};
    if strcmp(db.probe,'NP1')
      SR = 2500; % sampling rate for NP1
    elseif strcmp(db.probe,'NP24')
      SR = 30000; % sampling rate for NP2
    end
    
    % Get LFP signal for specified channel
    LFP  = getContinuousDataFromDatfile(LFPfile, totalchans, 0, +inf, rec_map.lfpchan, SR); % load raw LFP
    LFP  = resample(LFP(1:end-1), 1000, SR); % change to 1KHz resolution
    LFP = LFP - mean(LFP);
        
    % Check stimulus triggered LFP for all stimulus
    [RF.allstim_response] = find_mean_lfp_stim(LFP,rec_map.frametimes,rec_map.stim,rec_map.buffer);
        
    % Find stim centre coords of all stim positions
    centre_coord = NaN(size(rec_map.det,1),2);
    for s = 1:size(rec_map.det,1)
      x_coord = rec_map.det(s,3)-0.5*(rec_map.det(s,3)-rec_map.det(s,6));
      y_coord = rec_map.det(s,4)-0.5*(rec_map.det(s,4)-rec_map.det(s,7));
      centre_coord(s,:) = [x_coord y_coord];
    end
    clear x_coord y_coord s
    
    % Find stimulus triggered LFP for x coord
    for c = 1:numel(rec_map.coords) % for each coord (x and y)
        ID = find(centre_coord(:,c) == rec_map.coords(c));
        ID_frametimes = rec_map.frametimes(rec_map.ID == ID);
        [coord_response] = find_mean_lfp_stim(LFP,ID_frametimes,rec_map.stim,rec_map.buffer);
        RF.coord_response{c} = coord_response;
    end


end