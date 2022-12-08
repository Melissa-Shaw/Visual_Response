% Function to plot summary tiled figure for single experiment.
    % Inputs:
        % db --> singular db struct (db(exp)) with recording details (see makedb_TCB2_MS.m)
        % exp --> experiment number of recording
        % VR --> struct with visual responses to all stimuli (see CREATE_VR.m)
        % smth --> smoothing factor for LFP and poprate plots in ms
function plot_exp_summary_figures(db_exp,exp,VR,smth)
    conditions = {'Pre' 'Post'};

    % Set up summary figure
    figure
    set(gcf,'color','w');
    set(gcf, 'Position', get(0, 'Screensize'));
    T = tiledlayout(2,4);
    title(T,['Exp = ' num2str(exp) ' Num_units = ' num2str(sum(VR.units))],interpreter = 'None');
    
    % Plot spike raster
    [ax1] = nexttile;
    plotSpikeRaster(VR.neuronFR>0,'PlotType','vertline');
    xlabel('Time (s)');
    ylabel('Neuron (idx)');
    for c = 2:(numel(VR.cond_timepoints/1000)-1)
      xline(VR.cond_timepoints(c)/1000,'r');
      txt = text(VR.cond_timepoints(c)/1000,-0.3,db_exp.injection{c},Interpreter = 'none');
      set(txt,'Rotation',90);
    end
    axis square; box off;

    % Plot population rate
    [ax2] = nexttile;
    g = gausswin(smth); g = g/sum(g); popFR = conv(VR.popFR,g','same'); % smooth freq power
    plot(popFR);
    for c = 2:(numel(VR.cond_timepoints)-1)
      xline(VR.cond_timepoints(c)/1000,'r');
    end
    xlabel('Time (s)');
    ylabel('Population FR (sp/s)');
    axis square; box off;

    % Plot LFP
    [ax3] = nexttile;
    freq_power = conv(VR.LFP.freq_power,g','same'); % smooth freq power
    plot(freq_power);
    for c = 2:(numel(VR.cond_timepoints)-1)
        xline(VR.cond_timepoints(c)/1000,'r');
    end
    yline(1);
    xlabel('Time (s)');
    ylabel('LFP Freq Power');
    title(['Freq bounds: ' num2str(VR.LFP.freq_bounds(1)) ' - ' num2str(VR.LFP.freq_bounds(2))]);
    axis square; box off;
    linkaxes([ax1 ax2 ax3],'x');
    clear c g popFR freq_power ax1 ax2 ax3 txt

    % Plot barchart of num sig units
    cond_sig_units = [sum(VR.nat.sig_response(1).type{1}) sum(VR.grat.sig_response(1).type{1}) sum(VR.grat.sig_response(1).type{2}) sum(VR.grat.sig_response(1).type{3}); ...
        sum(VR.nat.sig_response(2).type{1}) sum(VR.grat.sig_response(2).type{1}) sum(VR.grat.sig_response(2).type{2}) sum(VR.grat.sig_response(2).type{3})];
    nexttile
    x = categorical({'Pre' 'Post'}); x = reordercats(x,{'Pre','Post'});
    b = bar(x,cond_sig_units);
    ylabel('Num Sig Units'); legend({'Nat','Class','Inv','FF'},'Location','northwest'); legend box off;
    b(1).FaceColor = VR.nat.colour{1}; b(2).FaceColor = VR.grat.colour{1};
    b(3).FaceColor = VR.grat.colour{2}; b(4).FaceColor = VR.grat.colour{3};
    axis square; box off;
    clear cond_sig_units x b 
    
    % plot receptive mapping response
    if isfield(VR,'RF')
        coords = {'x' 'y'};
        for c = 1:numel(coords)
            nexttile;
            plot(VR.rec_map.edges,VR.RF.allstim_response,'color',[0.5 0.5 0.5]);
            hold on
            plot(VR.rec_map.edges,VR.RF.coord_response{c},'b');
            xline(0);
            xline(VR.rec_map.stim);
            xlabel('Time (ms)');
            title(['RF ' coords{c} ' coord: ' num2str(VR.rec_map.coords(c))]);
            subtitle(['LFPchan: ' num2str(VR.rec_map.lfpchan)]);
            axis square; box off;
        end
    end
    
    % Plot pre scatter of unit locations on probe
    for cond = 1:numel(conditions)
        nexttile
        [nat_leg] = plot_shank_location(VR.location(VR.nat.sig_response(cond).type{1}),VR.channel(VR.nat.sig_response(cond).type{1}),[VR.nat.colour{1} VR.nat.marker{1}]); 
        nat_leg{1} = ['Nat: ' num2str(sum(VR.nat.sig_response(1).type{1}))]; hold on;
        for t = 1:numel(VR.grat.stimtype)
            [leg_array.type{t}] = plot_shank_location(VR.location(VR.grat.sig_response(cond).type{t}),...
                VR.channel(VR.grat.sig_response(cond).type{t}),[VR.grat.colour{t} VR.grat.marker{t}]); % output is array of legend spaces for each marker
            leg_array.type{t}{1} = [VR.grat.stimtype{t} ': ' num2str(sum(VR.grat.sig_response(cond).type{t}))]; % change first value to num_sig_units
        end
        hold off;
        legend([nat_leg leg_array.type{1} leg_array.type{2} leg_array.type{3}],'Location','best'); legend box off;
        title(conditions{cond});
        axis square; box off;
        clear nat_leg leg_array
    end
    
    % Set up summary figure
    figure
    set(gcf,'color','w');
    set(gcf, 'Position', get(0, 'Screensize'));
    T = tiledlayout(2,4);
    title(T,['Exp = ' num2str(exp) ' Num_units = ' num2str(sum(VR.units))],interpreter = 'None');
    
    % Plot mean psth for visual responses
    axes = [];
    for cond = 1:numel(conditions)
        [ax1] = nexttile;
        plot_sig_psth_response(VR.nat,cond,conditions{cond});
        legend({'Nat'}); legend box off;
        subtitle(['Nat: ' num2str(sum(VR.nat.sig_response(cond).type{1}))]);
        [ax2] = nexttile;
        plot_sig_psth_response(VR.grat,cond,conditions{cond});
        legend({'Class' '' '' 'Inv' '' '' 'FF'}); legend box off;
        subtitle(['Class: ' num2str(sum(VR.grat.sig_response(cond).type{1})) ' Inv: ' num2str(sum(VR.grat.sig_response(cond).type{2})) ' FF: ' num2str(sum(VR.grat.sig_response(cond).type{3}))]);
        axes = [axes ax1 ax2];
    end
    linkaxes(axes,'y'); clear axes;

    % Plot response amplitudes preVpost to each stim
    nexttile
    plot_log_scatter(VR.nat.spont(1).type{1}(VR.nat.sig_units.type{1}),VR.nat.evoked(1).type{1}(VR.nat.sig_units.type{1}),[0.5 0.5 0.5],VR.nat.marker{1});
    hold on
    plot_log_scatter(VR.nat.spont(2).type{1}(VR.nat.sig_units.type{1}),VR.nat.evoked(2).type{1}(VR.nat.sig_units.type{1}),VR.nat.colour{1},VR.nat.marker{1});
    hold off
    xlabel('Spont FR'); ylabel('Evoked FR'); title([VR.nat.stimtype{1} ' N = ' num2str(sum(VR.nat.sig_units.type{1}))]);
    axis square; box off;
    for t = 1:numel(VR.grat.stimtype)
        nexttile;
        plot_log_scatter(VR.grat.spont(1).type{t}(VR.grat.sig_units.type{t}),VR.grat.evoked(1).type{t}(VR.grat.sig_units.type{t}),[0.5 0.5 0.5],VR.grat.marker{t});
        hold on
        plot_log_scatter(VR.grat.spont(2).type{t}(VR.grat.sig_units.type{t}),VR.grat.evoked(2).type{t}(VR.grat.sig_units.type{t}),VR.grat.colour{t},VR.grat.marker{t});
        hold off
        xlabel('Spont FR'); ylabel('Evoked FR'); title([VR.grat.stimtype{t} ' N = ' num2str(sum(VR.grat.sig_units.type{t}))]);
        axis square; box off;
    end
    

    %% LOCAL FUNCTIONS
    function plot_sig_psth_response(ViStim,cond,figure_title)
        for t = 1:numel(ViStim.stimtype)
            sig_psth = ViStim.psth(cond).type{t}(ViStim.sig_response(cond).type{t},:); % all units with sig response
            if size(sig_psth,1) == 0
                disp(['No sig units for: ' figure_title]);
            elseif size(sig_psth,1) == 1
                plot(ViStim.edges,sig_psth,ViStim.colour{1});
                xline(0);
                xline(ViStim.stim);
            else  
                M_psth = mean(sig_psth,'omitnan');
                plot_psth(M_psth,ViStim.stim,ViStim.edges,ViStim.colour{t});  % plot psth over all trials
            end
            hold on
        end
        title(figure_title);
        axis square; box off;
    end


end