
function [NAT,GRAT] = group_unit_responses(VR)

    % create empty arrays ready
    for cond = 1:2 % for pre and post conditions
        NAT(cond).psth = [];
        NAT(cond).psth_SEM = [];
        NAT(cond).sig_units = [];
        for type = 1:3 % for grating stimtypes
            GRAT(cond).psth{type} = [];
            GRAT(cond).psth_SEM{type} = [];
            GRAT(cond).stim_sig_units = [];
            GRAT(cond).sig_units = [];
        end
    end

    % extract visual responses
    for i = 1:numel(VR)
        for cond = 1:2 % for pre and post cond
            NAT(cond).psth = [NAT(cond).psth; VR(i).nat.psth{cond}];
            NAT(cond).psth_SEM = [NAT(cond).psth_SEM; VR(i).nat.psth{cond}];
            NAT(cond).sig_units = [NAT(cond).sig_units; VR(i).nat.sig_response{cond}];
            for type = 1:numel(VR(i).grat.stimtype)
                GRAT(cond).psth{type} = [GRAT(cond).psth{type}; VR(i).grat.psth{cond}{type}];
                GRAT(cond).psth_SEM{type} = [GRAT(cond).psth_SEM{type}; VR(i).grat.psth_SEM{cond}{type}];
            end
            GRAT(cond).stim_sig_units = [GRAT(cond).stim_sig_units; VR(i).grat.sig_response{cond}];
        end
    end

    % find grating units with sig response for all stimtypes
    for cond = 1:2
        GRAT(cond).sig_units = sum(GRAT(cond).stim_sig_units,2) == 3; % units with sig response to all 3 stimtypes
    end
    
end
