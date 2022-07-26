% Function to find psth for all neurons for given stimulus frametimes.
    % Inputs:
        % spiketimes --> cell array of spiketimes for each neuron x each trial
        % frameTimes --> array of frame times for each trial
        % edges --> bin edges for psth
        % M_baseFR --> array of mean baseline FR for each neuron
    % Outputs:
        % psth_neuron --> matrix of mean response for each neuron over buffer-stim-buffer time period
        % psth_SEM --> matrix of SEM response for each neuron over buffer-stim-buffer time period
function [psth_neuron,psth_SEM] = find_psth(spiketimes,frameTimes,edges,M_baseFR)
    for n = 1:size(spiketimes,1) % for each unit
      psth = zeros(numel(frameTimes),numel(edges));
      for f = 1:numel(frameTimes) % for each trial (frame)
        psth(f,:) = histc(spiketimes{n,f},edges);
      end
      conv_factor = 1000/(edges(2)-edges(1)); % conv_factor from binsize to 1 second
      psth = psth.*conv_factor; % spike count for 100ms bin *10 to be in spikes/s
      %psth = psth./M_baseFR(n); % normalised by baseline
      M_psth = mean(psth); 
      SEM_psth = std(psth)./sqrt(size(psth,1));
      psth_neuron(n,:) = M_psth;
      psth_SEM(n,:) = SEM_psth;
    end
 end