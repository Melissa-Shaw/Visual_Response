
function [GROUP] = group_unit_responses(VR,stim)
    
    % set parameters
    num_exp = numel(VR);
    if strcmp(stim,'nat')
        num_stimtype = numel(VR(1).nat.stimtype);
        GROUP.stimtype = VR(1).nat.stimtype;
        GROUP.colour = VR(1).nat.colour;
        GROUP.marker = VR(1).nat.marker;
        GROUP.stim = VR(1).nat.stim;
        GROUP.buffer = VR(1).nat.buffer;
    elseif strcmp(stim,'grat')
        num_stimtype = numel(VR(1).grat.stimtype);
        GROUP.stimtype = VR(1).grat.stimtype;
        GROUP.colour = VR(1).grat.colour;
        GROUP.marker = VR(1).grat.marker;
        GROUP.stim = VR(1).grat.stim;
        GROUP.buffer = VR(1).grat.buffer;
    end

    % create empty arrays ready
    for cond = 1:2 % for pre and post conditions
        for t = 1:num_stimtype % for grating stimtypes
            GROUP.psth(cond).type{t} = [];
            GROUP.psth_SEM(cond).type{t} = [];
            GROUP.spont(cond).type{t} = [];
            GROUP.evoked(cond).type{t} = [];
            GROUP.resp(cond).type{t} = [];
            GROUP.stim_sig_response(cond).type{t} = [];
        end
    end
    GROUP.sig_units = [];
    GROUP.M_baseFR = [];
    GROUP.location = [];

    % extract visual responses
    for i = 1:num_exp
        
        % find stim data
        if strcmp(stim,'nat')
            ViStim = VR(i).nat;
        elseif strcmp(stim,'grat')
            ViStim = VR(i).grat;
        end
        
        % find responses
        for cond = 1:2 % for pre and post cond
            for t = 1:num_stimtype % for each stim type
                GROUP.psth(cond).type{t} = [GROUP.psth(cond).type{t}; ViStim.psth(cond).type{t}];
                GROUP.psth_SEM(cond).type{t} = [GROUP.psth_SEM(cond).type{t}; ViStim.psth_SEM(cond).type{t}];
                GROUP.spont(cond).type{t} = [GROUP.spont(cond).type{t}; ViStim.spont(cond).type{t}];
                GROUP.evoked(cond).type{t} = [GROUP.evoked(cond).type{t}; ViStim.evoked(cond).type{t}];
                GROUP.resp(cond).type{t} = [GROUP.resp(cond).type{t}; ViStim.resp(cond).type{t}];
                GROUP.stim_sig_response(cond).type{t} = [GROUP.stim_sig_response(cond).type{t}; ViStim.sig_response(cond).type{t}];
            end
        end
        
        % find units sig for classical and inverse
        if strcmp(stim,'nat')
            GROUP.sig_units = [GROUP.sig_units; ViStim.sig_units.type{1}];
        elseif strcmp(stim,'grat')
            GROUP.sig_units = [GROUP.sig_units; (ViStim.sig_units.type{1} & ViStim.sig_units.type{2})];
        end
        
        % find baseline FR
        GROUP.M_baseFR = [GROUP.M_baseFR; VR(i).M_baseFR];
        GROUP.location = [GROUP.location; VR(i).location];
    end
    
    GROUP.sig_units = logical(GROUP.sig_units);
    for cond = 1:2
        for t = 1:num_stimtype
            GROUP.resp(cond).type{t}(GROUP.resp(cond).type{t} == Inf | GROUP.resp(cond).type{t} == -Inf) = NaN;
        end
    end
    
end
