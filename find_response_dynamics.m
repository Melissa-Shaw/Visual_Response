
function [resp_delay, rise_time] = find_response_dynamics(psth,buffer,stim)

% set parameters
stim_onset = buffer+1;
time_array = [-buffer:stim+buffer];
%z_threshold = 2.58; % p = 0.05

% z-score psth
mean_spont = mean(mean(psth(:,1:stim_onset-1),'omitnan'),'omitnan');
std_spont = std(std(psth(:,1:stim_onset-1),'omitnan'),'omitnan');
%psth = (psth - mean_spont)./std_spont; 
z_threshold = mean_spont + 3.*std_spont;

resp_delay = NaN(size(psth,1),1);
for n = 1:size(psth,1)
    resp_points = find(psth(n,:) > z_threshold);
    resp_points = resp_points(resp_points >= stim_onset & resp_points <= (stim_onset + stim));
    if ~isempty(resp_points)
        resp_delay(n) = time_array(resp_points(1))+1; % +1 to account from 0 time onset
    end
end

[~,max_point] = max(psth(:,stim_onset:stim_onset+stim),[],2);
rise_time = max_point - resp_delay;

end