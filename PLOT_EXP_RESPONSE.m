% load db struct
shared_drive = 'X:';
run([shared_drive '\cortical_dynamics\User\ms1121\Code\General\makedb_TCB2_MS']); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% set parameters
opt.smth = 250; % smoothing parameter (s) for LFP and population FR
opt.save_fig = true;

% create summary figure
for exp = 208%[149 199]
    
    % load VR
    [VR] = load_VR(shared_drive,db,exp);
    
    % plot summary figure
    plot_summary_figure(db(exp),exp,VR,opt.smth);
    
    % save summary figure
    if opt.save_fig == true
        disp('Saving summary figure...');
        savefig([shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_Summary.fig']);
        disp('Summary figure saved');
    end
    
end