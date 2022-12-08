% Function to plot psth with SEM shading around mean response.
    % Inputs:
        % M_psth --> psth response for one neuron (or mean) over buffer-stim-buffer time period
        % SEM_psth --> standard error of the mean of psth response
        % stim --> length of stim in ms
        % edges --> bin edges for psth
        % line_colour --> colour for line style and shading
function plot_psth(M_psth,stim,edges,line_colour)
    g = gausswin(10); g = g/sum(g); M_psth = conv(M_psth,g','same');
    plot(edges(1:end-1),M_psth(1:end-1),line_colour);
    xline(0);
    xline(stim);
end