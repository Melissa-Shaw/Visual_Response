% load db struct
shared_drive = 'X:';
run([shared_drive '\cortical_dynamics\User\ms1121\Code\General\makedb_TCB2_MS']); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% set parameters
opt.smth = 250; % smoothing parameter (s) for LFP and population FR
opt.save_fig = true;
opt.plot_unit_figures = true;

% create summary figure
for exp = [AwakeV1(11:end) AnaesV1]
    
    % load VR
    [VR] = load_VR(shared_drive,db,exp);
    
    % plot summary figure
    plot_exp_summary_figures(db(exp),exp,VR,opt.smth);
    
    % save summary figure
    if opt.save_fig == true
        disp('Saving summary figures...');
        FolderPath = [shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_' db(exp).syringe_contents '\'];
        if ~exist(FolderPath,'dir')
            mkdir(FolderPath);
        end
        save_all_figures(FolderPath,['Exp_' num2str(exp) '_Summary.fig']);
        close all
    end
    
    % plot unit summary figures
    if opt.plot_unit_figures == true
        disp('Plotting unit figures...');
        clusters = VR.clusteridx(VR.grat.sig_units.type{1});
        plot_unit_summary_figures(db,exp,VR,clusters,opt.save_fig,'Class_Units');
        clusters = VR.clusteridx(VR.grat.sig_units.type{1} & VR.grat.sig_units.type{2});
        plot_unit_summary_figures(db,exp,VR,clusters,opt.save_fig,'ClassInv_Units');
    end
    
end