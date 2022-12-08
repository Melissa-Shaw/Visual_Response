function plot_unit_summary_figures(db,exp,VR,clusters,save_figure,save_folder)

    conditions = {'Pre','Post'};

    for i = 1:numel(clusters)
        
        % find unit
        clu = clusters(i);
        n = find(VR.clusteridx==clu);
        
        %set up figure
        figure
        T = tiledlayout(2,5);
        %title(T,['Clu: ' num2str(clu) ' ' VR.location{n}],'Interpreter','None');
        set(gcf,'color','w');
        set(gcf, 'Position', get(0, 'Screensize'));

        % plot psth, raster and directional response
        axes = [];
        for cond = 1:numel(conditions)
            ax1 = nexttile;
            plot_stim_psth(VR.nat,cond,n); title(conditions(cond));
            legend({'Nat'}); legend box off;
            nexttile;
            plot_stim_raster(VR.nat,cond,n); title(conditions(cond));

            ax2 = nexttile;
            plot_stim_psth(VR.grat,cond,n); title(conditions(cond));
            legend({'Class' '' '' 'Inv' '' '' 'FF' '' ''}); legend box off;
            nexttile;
            plot_stim_raster(VR.grat,cond,n); title(conditions(cond));

            axes = [axes ax1 ax2];
            
            % find statistical significance of direction preference
            KW_p = [];
            for t = 1:numel(VR.grat.stimtype)
                [~,p] = find_statistical_dir_preference(VR.grat.evoked(cond).type_dir_trial,t,n);
                KW_p = [KW_p p];
            end
            
            nexttile;
            [resp] = plot_dir_response(VR.grat,cond,n); title(conditions(cond));
            title('Directional Evoked FR');
            subtitle(['p_class = ' num2str(KW_p(1)) ' p_inv = ' num2str(KW_p(2)) ' p_FF = ' num2str(KW_p(3))],'Interpreter','None');
            
        end
        linkaxes(axes,'y');
        title(T,['Clu: ' num2str(clu) ' ' VR.location(n)],'Interpreter','None');
        
        % save figure
        if save_figure == true
            FolderPath = ['X:\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_' db(exp).syringe_contents '\' save_folder '\'];
            if ~exist(FolderPath,'dir')
                mkdir(FolderPath);
            end
            savefig([FolderPath '\Unit_' num2str(clu) '_Summary.fig']);
            close all
        end
    end
        
        
        
    %% LOCAL FUNCTIONS
    function plot_stim_psth(ViStim,cond,n)
       for t = 1:numel(ViStim.stimtype)
            plot_psth(ViStim.psth(cond).type{t}(n,:),ViStim.stim,ViStim.edges,ViStim.colour{t});
            hold on
       end
       hold off
       xlabel('Time (ms)'); ylabel('Firing Rate (sp/s)');
       xlim([-ViStim.buffer ViStim.stim+ViStim.buffer]);
       axis square
       box off
    end

    function plot_stim_raster(ViStim,cond,n)
        spiketimes_all = [];
        for t = 1:numel(ViStim.stimtype)
            spiketimes_all = [spiketimes_all ViStim.spiketimes(cond).type{t}];
        end
        colour_struct.color = ViStim.colour{1};
        [xPoints,yPoints,lineFormat] = plotSpikeRaster(spiketimes_all(n,:)','PlotType','vertline','LineFormat',colour_struct,'XLimForCell',[-ViStim.buffer ViStim.stim+ViStim.buffer]);
        hold on
        if numel(ViStim.stimtype) > 1
            for t = 2:numel(ViStim.stimtype)
                lineFormat{2} = ViStim.colour{t};
                pts = find(yPoints > (t-1)*ViStim.num_frames_stimtype & yPoints <= t*ViStim.num_frames_stimtype);
                plot(xPoints(min(pts):max(pts)),yPoints(min(pts):max(pts)),'k',lineFormat{:});
            end
        end
        xlabel('Time (ms)'); ylabel('Trials');
        axis square
        box off
    end

    function [resp] = plot_dir_response(ViStim,cond,n)
        %resp = NaN(numel(ViStim.directions),numel(ViStim.stimtype));
        resp = NaN(numel(ViStim.stimtype),numel(ViStim.directions));
        directions = {};
        for t = 1:numel(ViStim.stimtype)
            for d = 1:numel(ViStim.directions)
                %resp(d,t) = ViStim.resp(cond).type_dir{d,t}(n);
                resp(t,d) = ViStim.evoked(cond).type_dir{d,t}(n);
                if t == 1
                    directions = [directions num2str(ViStim.directions(d))];
                end
            end
            %plot(ViStim.directions,resp(:,t),[ViStim.colour{t} '-o'],'MarkerFaceColor',ViStim.colour{t});
            %hold on
        end
        RGB_colours = [0 0 0; 1 0 0; 0 0 1];
        %axis_limits = [repelem(min(min(resp)),8);repelem(max(max(resp)),8)];
        axis_limits = [zeros(1,8);repelem(max(max(resp)),8)];
        if max(max(resp)) > 0
            spider_plot(resp,'color',RGB_colours,'AxesLimits',axis_limits,'AxesLabels',directions);
        end
        %hold off
        %xlabel(['Direction (' char(176) ')']); ylabel('Resp (E/S)'); yline(1);
        axis square; box off;
    end   


    function [dir_resp,p] = find_statistical_dir_preference(ViStim_resp,type,n)
        dir_resp = [];
        for d = 1:size(ViStim_resp,1)
            unit_resp = ViStim_resp{d,type}(n,:);
            dir_resp = [dir_resp unit_resp'];
        end
        p = kruskalwallis(dir_resp,[],'off');
    end
            
        
        
        
        
        
        
        
end