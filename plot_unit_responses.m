% Function to plot neuron psth and raster responses for given experiment.
    % Inputs:
        % VR --> struct with visual responses to all stimuli (see CREATE_VR.m)
        % units --> logical array of neurons to be plotted
        % vis_stim --> string input of which type of stimulation is of interest ('nat' or 'grat')
        % presentation --> string input of which presentation condition is of interest ('pre' or 'post')
    % Outputs:
        % T --> tiled figure handle
function [T] = plot_unit_responses(VR,units,vis_stim,presentation) % units is logical array of sig neurons
    % extract responses of interest
    if strcmp(vis_stim,'nat')
        ViStim = VR.nat;
    elseif strcmp(vis_stim,'grat')
        ViStim = VR.grat;
    end
    if strcmp(presentation,'pre')
        cond = 1;
    elseif strcmp(presentation,'post')
        cond = 2;
    end

    % prepare spiketimes input for raster function
    spiketimes_all = [];
    if numel(ViStim.stimtype) > 1
        for type = 1:numel(ViStim.stimtype)
            spiketimes_all = [spiketimes_all ViStim.spiketimes{cond}{type}];
        end
    else
        spiketimes_all = ViStim.spiketimes{cond};
    end
    
    % set up figure
    figure
    T = tiledlayout(4,6);
    count = 1;
    for n = 1:numel(units) % for each neuron
        if units(n) == 1 % if unit is significant
            
            % maximum 24 tiles to each figure
            if count > 24 
                figure
                tiledlayout(4,6);
                count = 1;
            end
            
            % plot psth of each stimtype
            nexttile
            g = gausswin(100); g = g/sum(g);
            if numel(ViStim.stimtype) > 1
                for type = 1:numel(ViStim.stimtype)
                    M_psth = ViStim.psth{cond}{type}(n,:); M_psth = conv(M_psth,g','same');
                    plot(ViStim.edges(1:end-1),M_psth(1:end-1),ViStim.colour{type});
                    xline(0);
                    xline(ViStim.stim);
                    hold on
                end
                hold off
            else
                plot_psth(ViStim.psth{cond}(n,:),ViStim.psth_SEM{cond}(n,:),ViStim.stim,ViStim.edges,ViStim.colour{1});
            end        
            title(['Clu: ' num2str(VR.clusteridx(n)) ' Ch: ' num2str(VR.channel(n)) ' ' VR.location{n}],'interpreter','None');
            
            % plot raster - colour coded if more than one stimtype
            nexttile
            colour_struct.color = ViStim.colour{1};
            [xPoints,yPoints,lineFormat] = plotSpikeRaster(spiketimes_all(n,:)','PlotType','vertline','LineFormat',colour_struct,'XLimForCell',[-ViStim.buffer ViStim.buffer+ViStim.stim]);
            if numel(ViStim.stimtype) > 1
                hold on
                for type = 2:numel(ViStim.stimtype)
                    lineFormat{2} = ViStim.colour{type};
                    pts = find(yPoints > (type-1)*ViStim.num_frames_stimtype & yPoints <= type*ViStim.num_frames_stimtype);
                    plot(xPoints(min(pts):max(pts)),yPoints(min(pts):max(pts)),'k',lineFormat{:});
                end
            end
            xlabel('Time (ms)'); ylabel('Trials');
            count = count + 2;
        end
    end