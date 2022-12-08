% Function to find neurons with significant responses to stimuli.
    % Inputs:
        % psth_neuron --> psth_neuron --> matrix of mean response for each neuron over buffer-stim-buffer time period
        % buffer --> length of buffer in ms
        % stim --> length of stim in ms
        % binsize --> binsize used for psth in ms
        % sig_threshold --> p_value cut off for significance
    % Outputs:
        % p_values --> array of p_values for each neuron's response
        % sig_response --> logical array of which neurons showed significant response
function [p_values,sig_response] = find_sig_neurons(psth_neuron,buffer,stim,binsize,sig_threshold)
  num_units = size(psth_neuron,1);
  p_values = NaN(num_units,1);
  onset_bin = (buffer/binsize)+1;
  offset_bin = (buffer+stim)/binsize;
  for n = 1:num_units
    psth = psth_neuron(n,:);
    response = psth(onset_bin:offset_bin);
    baseline = psth(1:onset_bin-1);
    if buffer <= stim
      [p] = signrank(baseline,response(1:numel(baseline)));
    else
      [p] = signrank(baseline(1:numel(response)),response);
    end
    %p_values(n) = round(p,3);
    p_values(n) = p;
  end
  sig_response = p_values < sig_threshold;
end