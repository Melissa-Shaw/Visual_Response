
function plot_directional_responses(ViStim,figure_title)
    
    % set up figure
    figure
    T = tiledlayout(2,2);
    title(T,figure_title);
    set(gcf,'color','w');
    
    % plot resp vs direction for each stimtype
    pos = 1;
    for cond = 1:2
        nexttile
        resp = NaN(numel(ViStim.directions),numel(ViStim.stimtype));
        for t = 1:numel(ViStim.stimtype)
            for d = 1:numel(ViStim.directions)
                resp(d,t) = nanmean(ViStim.resp(cond).type_dir{d,t});
            end
            plot(ViStim.directions,resp(:,t),[ViStim.colour{t} '-o'],'MarkerFaceColor',ViStim.colour{t});
            hold on
        end
        hold off
        xlabel(['Direction (' char(176) ')']); ylabel('Resp (E/S)'); yline(1);
        if cond == 1
            title('Pre');
        elseif cond == 2
            title('Post');
        end
        axis square; box off;
    end          

    % plot spider of directional responses
    %for cond = 1:2 
    %    nexttile
    %    plot_spider_response(ViStim,ViStim.resp(cond)); title('Resp (E/S)');
    %end
    
    % plot psth responses for each stimtype at each direction
    %figure
    %set(gcf,'color','w');
    %T = tiledlayout(4,4);
    %title(T,figure_title);
    %for cond = 1:2
    %    for d = 1:numel(ViStim.directions)
    %        nexttile
    %        for t = 1:numel(ViStim.stimtype)
    %            M_psth = mean(ViStim.psth(cond).type_dir{d,t},1);
    %            SEM_psth = std(ViStim.psth(cond).type_dir{d,t},1)./sqrt(size(ViStim.psth(cond).type_dir{d,t},1));
    %            plot_psth(M_psth,SEM_psth,ViStim.stim,ViStim.edges,ViStim.colour{t});
    %            hold on
    %        end
    %        hold off
    %        xlabel('Time (ms)'); ylabel('FR (sp/s)'); 
    %        if cond == 1
    %            title(['Pre ' num2str(ViStim.directions(d)) char(176)]);
    %        elseif cond == 2
    %            title(['Post ' num2str(ViStim.directions(d)) char(176)]);
    %        end
    %    end
    %end
    
    %% LOCAL FUNCTIONS
    %function [spont] = plot_spider_response(ViStim,response)
    %    spont = NaN(numel(ViStim.stimtype),numel(ViStim.directions));
    %    AxesLimits = spont(1:2,:);
    %    AxesLabels = {'0' '45' '90' '135' '180' '225' '270' '315'};
    %    colours = [0 0 0; 1 0 0; 0 0 1];
    %    for d = 1:numel(ViStim.directions)
    %        for t = 1:numel(ViStim.stimtype)
    %            spont(t,d) = nanmean(response.type_dir{d,t});
    %        end
    %    end
    %    AxesLimits(1,:) = min(min(spont)); AxesLimits(2,:) = max(max(spont));
    %    spider_plot(spont,'AxesLabels',AxesLabels,'AxesLimits',AxesLimits,'Color',colours);
    %end
    
    
    
    
end
    