function plot_unit_preVpost(clu,VR)
    
    n = find(VR.clusteridx==clu);
    conditions = {'Pre','Post'};

    figure
    T = tiledlayout(2,4);
    
    for cond = 1:numel(conditions)
        % natural images psth
        nexttile
        plot_psth(VR.nat.psth{cond}(n,:),VR.nat.psth_SEM{cond}(n,:),VR.nat.stim,VR.nat.edges,VR.nat.colour{1});
        title(['Natural Images ' conditions{cond}]);
        % natural images raster
        nexttile
        spiketimes_all = VR.nat.spiketimes{cond};
        colour_struct.color = VR.nat.colour{1};
        plotSpikeRaster(spiketimes_all(n,:)','PlotType','vertline','LineFormat',colour_struct,'XLimForCell',[-VR.nat.buffer VR.nat.buffer+VR.nat.stim]);
        xlabel('Time (ms)'); ylabel('Trials');    
    
        % grating stim psth
        nexttile
        for type = 1:numel(VR.grat.stimtype)
            plot_psth(VR.grat.psth{cond}{type}(n,:),VR.grat.psth_SEM{cond}{type}(n,:),VR.grat.stim,VR.grat.edges,VR.grat.colour{type});
            hold on
        end
        hold off
        %legend({'','Class','','','','Inv','','','','FullField'});
        legend({'Class','','','Inv','','','FullField'});
        title(['Grating ' conditions{cond}]);
        % grating stim raster
        nexttile
        spiketimes_all = [];
        for type = 1:numel(VR.grat.stimtype)
            spiketimes_all = [spiketimes_all VR.grat.spiketimes{cond}{type}];
        end
        colour_struct.color = VR.grat.colour{1};
        [xPoints,yPoints,lineFormat] = plotSpikeRaster(spiketimes_all(n,:)','PlotType','vertline','LineFormat',colour_struct,'XLimForCell',[-VR.grat.buffer VR.grat.buffer+VR.grat.stim]);
        hold on
        for type = 2:numel(VR.grat.stimtype)
            lineFormat{2} = VR.grat.colour{type};
            pts = find(yPoints > (type-1)*VR.grat.num_frames_stimtype & yPoints <= type*VR.grat.num_frames_stimtype);
            plot(xPoints(min(pts):max(pts)),yPoints(min(pts):max(pts)),'k',lineFormat{:});
        end
        xlabel('Time (ms)'); ylabel('Trials');
    end
         
    title(T,['Clu: ' num2str(VR.clusteridx(n)) ' Ch: ' num2str(VR.channel(n)) ' ' VR.location{n}],'interpreter','None');

end