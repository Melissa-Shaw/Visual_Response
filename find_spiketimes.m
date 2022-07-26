% Function to find spiketimes of each neuron in response to each trial.
    % Inputs:
        % spike_raster --> spike raster of all neurons to be included
        % frametimes --> frame times of trials to be included
        % buffer --> length of buffer between trials in ms
        % stimulus --> length of each stimulus in ms
    % Outputs:
        % spiketimes --> cell array of spiketimes for each neuron x each trial
function [spiketimes] = find_spiketimes(spike_raster,frameTimes,buffer,stimulus)
  num_units = size(spike_raster,1);
  num_trials = numel(frameTimes);
  spiketimes = cell(num_units,num_trials);
  for n = 1:num_units
    for f = 1:num_trials
      trial_response = spike_raster(n,frameTimes(f)-buffer:frameTimes(f)+stimulus-1+buffer); % extract spike data for time around stimulus onset (stim-1 so onset is count=0)
      trial_spiketimes = find(trial_response > 0);
      spiketimes{n,f} = trial_spiketimes - buffer - 1; 
    end
  end
end
