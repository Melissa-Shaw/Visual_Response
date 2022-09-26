% Function to plot summary tiled figure for single experiment.
    % Inputs:
        % db --> singular db struct (db(exp)) with recording details (see makedb_TCB2_MS.m)
        % exp --> experiment number of recording
        % VR --> struct with visual responses to all stimuli (see CREATE_VR.m)
        % smth --> smoothing factor for LFP and poprate plots in ms
function plot_summary_figure(db,exp,VR,smth)
    %% Set up summary figure
    figure
    sum_fig = tiledlayout(4,4);
    title(sum_fig,['Exp = ' num2str(exp) ' Num_units = ' num2str(sum(VR.units))],interpreter = 'None');

    % Plot spike raster
    [ax1] = nexttile(1);
    plotSpikeRaster(VR.neuronFR>0,'PlotType','vertline');
    xlabel('Time (s)');
    ylabel('Neuron (idx)');
    for c = 2:(numel(VR.cond_timepoints/1000)-1)
      xline(VR.cond_timepoints(c)/1000,'r');
      txt = text(VR.cond_timepoints(c)/1000,-0.3,db.injection{c},Interpreter = 'none');
      set(txt,'Rotation',90);
    end

    % Plot population rate
    [ax2] = nexttile(2);
    g = gausswin(smth); g = g/sum(g); popFR = conv(VR.popFR,g','same'); % smooth freq power
    plot(popFR);
    for c = 2:(numel(VR.cond_timepoints)-1)
      xline(VR.cond_timepoints(c)/1000,'r');
    end
    xlabel('Time (s)');
    ylabel('Population FR (sp/s)');

    % Plot LFP
    [ax3] = nexttile(3);
    freq_power = conv(VR.LFP.freq_power,g','same'); % smooth freq power
    plot(freq_power);
    for c = 2:(numel(VR.cond_timepoints)-1)
        xline(VR.cond_timepoints(c)/1000,'r');
    end
    yline(1);
    xlabel('Time (s)');
    ylabel('LFP Freq Power');
    title(['Freq bounds: ' num2str(VR.LFP.freq_bounds(1)) ' - ' num2str(VR.LFP.freq_bounds(2))]);

    linkaxes([ax1 ax2 ax3],'x');
    clear c g popFR freq_power ax1 ax2 ax3 txt

    % Plot receptive mapping response
    if isfield(VR,'RF')
        % X coord
        nexttile(5);
        plot(VR.rec_map.edges,VR.RF.allstim_response,'color',[0.5 0.5 0.5]);
        hold on
        plot(VR.rec_map.edges,VR.RF.coord_response{1},'b');
        xline(0);
        xline(VR.rec_map.stim);
        xlabel('Time (ms)');
        title(['RF  x coord: ' num2str(VR.rec_map.coords(1))]);
        subtitle(['LFPchan: ' num2str(VR.rec_map.lfpchan)]);

        % Y coord
        nexttile(6);
        plot(VR.rec_map.edges,VR.RF.allstim_response,'color',[0.5 0.5 0.5]);
        hold on
        plot(VR.rec_map.edges,VR.RF.coord_response{2},'b');
        xline(0);
        xline(VR.rec_map.stim);
        xlabel('Time (ms');
        title(['RF y coord: ' num2str(VR.rec_map.coords(2))]);
        subtitle(['LFPchan: ' num2str(VR.rec_map.lfpchan)]);
    end

    % Plot mean psth for visual responses
    % Pre Nat Stim
    [ax1] = nexttile(7);
    sig_psth = VR.nat.psth{1}(VR.nat.sig_response{1},:); % all units with sig pre response
    if size(sig_psth,1) == 0
        disp(['No sig units for pre nat stim.']);
    elseif size(sig_psth,1) == 1
        plot(VR.nat.edges,sig_psth,VR.nat.colour{1});
        xline(0);
        xline(VR.nat.stim);
    else  
        M_psth = nanmean(sig_psth);
        M_SEM_psth = (nanstd(sig_psth))./(sqrt(size(sig_psth,1)));
        plot_psth(M_psth,M_SEM_psth,VR.nat.stim,VR.nat.edges,VR.nat.colour{1});  % plot psth over all trials
    end
    title(['Pre Nat: ' num2str(size(sig_psth,1)) ' sig units']);


    % Post Nat Stim
    [ax2] = nexttile(8);
    sig_psth = VR.nat.psth{2}(VR.nat.sig_response{2},:); % all units with sig post response
    if size(sig_psth,1) == 0
        disp(['No sig units for post nat stim.']);
    elseif size(sig_psth,1) == 1
        plot(VR.nat.edges,sig_psth,VR.nat.colour{1});
        xline(0);
        xline(VR.nat.stim);
    else  
        M_psth = nanmean(sig_psth);
        M_SEM_psth = (nanstd(sig_psth))./(sqrt(size(sig_psth,1)));
        plot_psth(M_psth,M_SEM_psth,VR.nat.stim,VR.nat.edges,VR.nat.colour{1});  % plot psth over all trials
    end
    title(['Post Nat: ' num2str(size(sig_psth,1)) ' sig units']);
    %linkaxes([ax1 ax2],'xy');

    % Pre Grat Stim
    [ax1] = nexttile(11);
    for t = 1:numel(VR.grat.stimtype)
        sig_psth = VR.grat.psth{1}{t}(VR.grat.sig_response{1}(:,t),:);
        if size(sig_psth,1) == 0
            disp(['No sig units for pre grat stimtype: ' num2str(t)]);
        elseif size(sig_psth,1) == 1
            plot(VR.grat.edges,sig_psth,VR.grat.colour{t});
            xline(0);
            xline(VR.grat.stim);
        else  
            M_psth = nanmean(sig_psth);
            M_SEM_psth = (nanstd(sig_psth))./(sqrt(size(sig_psth,1)));
            plot_psth(M_psth,M_SEM_psth,VR.grat.stim,VR.grat.edges,VR.grat.colour{t});  % plot psth over all trials
        end
        hold on
    end
    pre_sig_grat_units = VR.grat.sig_response{1}(:,1) & VR.grat.sig_response{1}(:,2) & VR.grat.sig_response{1}(:,3);
    title(['Pre Grat: ' num2str(sum(pre_sig_grat_units))]);
    subtitle(['Class: ' num2str(sum(VR.grat.sig_response{1}(:,1))) ' Inv: ' num2str(sum(VR.grat.sig_response{1}(:,2))) ' FF: ' num2str(sum(VR.grat.sig_response{1}(:,3)))]);

    % Post Grat Stim
    [ax1] = nexttile(12);
    for t = 1:numel(VR.grat.stimtype)
        sig_psth = VR.grat.psth{2}{t}(VR.grat.sig_response{2}(:,t),:);
        if size(sig_psth,1) == 0
            disp(['No sig units for post grat stimtype: ' num2str(t)]);
        elseif size(sig_psth,1) == 1
            plot(VR.grat.edges,sig_psth,VR.grat.colour{t});
            xline(0);
            xline(VR.grat.stim);
        else  
            M_psth = nanmean(sig_psth);
            M_SEM_psth = (nanstd(sig_psth))./(sqrt(size(sig_psth,1)));
            plot_psth(M_psth,M_SEM_psth,VR.grat.stim,VR.grat.edges,VR.grat.colour{t});  % plot psth over all trials
        end
        hold on
    end
    post_sig_grat_units = VR.grat.sig_response{2}(:,1) & VR.grat.sig_response{2}(:,2) & VR.grat.sig_response{2}(:,3);
    title(['Post Grat: ' num2str(sum(post_sig_grat_units))]);
    subtitle(['Class: ' num2str(sum(VR.grat.sig_response{2}(:,1))) ' Inv: ' num2str(sum(VR.grat.sig_response{2}(:,2))) ' FF: ' num2str(sum(VR.grat.sig_response{2}(:,3)))]);
    %linkaxes([ax1 ax2],'xy');
    clear sig_psth M_psth M_SEM_psth t ax1 ax2

    % Plot pre scatter of unit locations on probe
    nexttile(9)
    [nat_leg] = plot_shank_location(VR.location(VR.nat.sig_response{1}),VR.channel(VR.nat.sig_response{1}),'gx'); 
    nat_leg{1} = ['Nat: ' num2str(sum(VR.nat.sig_response{1}))]; hold on;
    [class_leg] = plot_shank_location(VR.location(VR.grat.sig_response{1}(:,1)),VR.channel(VR.grat.sig_response{1}(:,1)),'ko');
    class_leg{1} = ['Class: ' num2str(sum(VR.grat.sig_response{1}(:,1)))];
    [inv_leg] = plot_shank_location(VR.location(VR.grat.sig_response{1}(:,2)),VR.channel(VR.grat.sig_response{1}(:,2)),'r+');
    inv_leg{1} = ['Inv: ' num2str(sum(VR.grat.sig_response{1}(:,2)))];
    [ff_leg] = plot_shank_location(VR.location(VR.grat.sig_response{1}(:,3)),VR.channel(VR.grat.sig_response{1}(:,3)),'b.'); 
    ff_leg{1} = ['FullField: ' num2str(sum(VR.grat.sig_response{1}(:,3)))]; hold off;
    legend([nat_leg class_leg inv_leg ff_leg],'Location','best');
    title('Pre Responsive Unit Locations');
    
    % Plot post scatter of unit locations on probe
    nexttile(10)
    [nat_leg] = plot_shank_location(VR.location(VR.nat.sig_response{2}),VR.channel(VR.nat.sig_response{2}),'gx'); 
    nat_leg{1} = ['Nat: ' num2str(sum(VR.nat.sig_response{2}))]; hold on;
    [class_leg] = plot_shank_location(VR.location(VR.grat.sig_response{2}(:,1)),VR.channel(VR.grat.sig_response{2}(:,1)),'ko');
    class_leg{1} = ['Class: ' num2str(sum(VR.grat.sig_response{2}(:,1)))];
    [inv_leg] = plot_shank_location(VR.location(VR.grat.sig_response{2}(:,2)),VR.channel(VR.grat.sig_response{2}(:,2)),'r+');
    inv_leg{1} = ['Inv: ' num2str(sum(VR.grat.sig_response{2}(:,2)))];
    [ff_leg] = plot_shank_location(VR.location(VR.grat.sig_response{2}(:,3)),VR.channel(VR.grat.sig_response{2}(:,3)),'b.'); 
    ff_leg{1} = ['FullField: ' num2str(sum(VR.grat.sig_response{2}(:,3)))]; hold off;
    legend([nat_leg class_leg inv_leg ff_leg],'Location','best');
    title('Post Responsive Unit Locations');
    
    % Plot barchart of num sig units
    cond_sig_units = [sum(VR.nat.sig_response{1}) sum(pre_sig_grat_units) sum(VR.grat.sig_response{1}); ...
        sum(VR.nat.sig_response{2}) sum(post_sig_grat_units) sum(VR.grat.sig_response{2})];
    nexttile(4)
    x = categorical({'Pre' 'Post'}); x = reordercats(x,{'Pre','Post'});
    b = bar(x,cond_sig_units);
    ylabel('Num Sig Units'); legend({'Nat','All Grat','Class','Inv','FF'},'Location','best');
    b(1).FaceColor = VR.nat.colour{1}; b(2).FaceColor = 'y'; b(3).FaceColor = VR.grat.colour{1};
    b(4).FaceColor = VR.grat.colour{2}; b(5).FaceColor = VR.grat.colour{3};
    clear cond_sig_units x b 

    % Plot response amplitudes preVpost to each stim
    nat_sig = VR.nat.sig_response{1} | VR.nat.sig_response{2};
    grat_sig = sum(VR.grat.sig_response{1},2) == 3 | sum(VR.grat.sig_response{2},2) == 3;

    nexttile(13)
    plot_log_scatter(VR.nat.resp_amp{1}(nat_sig),VR.nat.resp_amp{2}(nat_sig),'gx');
    xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['Nat N = ' num2str(sum(nat_sig))]);
    nexttile(14)
    plot_log_scatter(VR.grat.resp_amp{1}{1}(grat_sig),VR.grat.resp_amp{2}{1}(grat_sig),'ko');
    xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['Class N = ' num2str(sum(grat_sig))]);
    nexttile(15)
    plot_log_scatter(VR.grat.resp_amp{1}{2}(grat_sig),VR.grat.resp_amp{2}{2}(grat_sig),'r+');
    xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['Inv N = ' num2str(sum(grat_sig))]);
    nexttile(16)
    plot_log_scatter(VR.grat.resp_amp{1}{3}(grat_sig),VR.grat.resp_amp{2}{3}(grat_sig),'b.');
    xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['FullField N = ' num2str(sum(grat_sig))]);
    

end