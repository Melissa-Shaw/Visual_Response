%% Script to plot and save unit psth responses and raster for all stimulus types of all significant neurons.

%% Set up
shared_drive = 'X:';
addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\General']);

% load db struct
run('makedb_TCB2_MS'); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% set script options - TEMP MEASURE TO MAKE SCRIPT FLEXIBLE WHILE CODING
opt.save_indv_fig = true;


for exp = [AnaesV1(6:8) AwakeV1(19:22)]

    % load VR
    [VR] = load_VR('X:',db,exp);
    
    % set up save folder if required
    if opt.save_indv_fig == true
        close all % close all other open figures
        FolderPath = [shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_Unit_Figures\All_Responses\'];
        nat_path = [shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_Unit_Figures\Nat_Responses\'];
        grat_path = [shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_Unit_Figures\Grat_Responses\'];
        mkdir(FolderPath); mkdir(nat_path); mkdir(grat_path);
    end

    % plot natural images responses
    [T] = plot_unit_responses(VR,VR.nat.sig_response{1},'nat','pre');
    title(T,['Pre Nat Stim: ' num2str(sum(VR.nat.sig_response{1})) ' sig units']);
    if opt.save_indv_fig == true
        save_all_figures(FolderPath,'Nat_pre');
        close all
    end
    
    [T] = plot_unit_responses(VR,VR.nat.sig_response{2},'nat','post');
    title(T,['Post Nat Stim: ' num2str(sum(VR.nat.sig_response{2})) ' sig units']);
    if opt.save_indv_fig == true
        save_all_figures(FolderPath,'Nat_post');
        close all
    end
    
    
    % plot grating images responses
    sig_units = VR.grat.sig_response{1}(:,1) | VR.grat.sig_response{1}(:,2) | VR.grat.sig_response{1}(:,3); % units with sig response to at least one stimtype
    [T] = plot_unit_responses(VR,sig_units,'grat','pre');
    title(T,['Pre Grat Stim: ' num2str(sum(sig_units)) ' sig units']);
    subtitle(T,['Class = black, ','Inv = red, ','FF = blue']);
    if opt.save_indv_fig == true
        save_all_figures(FolderPath,'Grat_pre');
        close all
    end
    
    sig_units = VR.grat.sig_response{2}(:,1) | VR.grat.sig_response{2}(:,2) | VR.grat.sig_response{2}(:,3);
    [T] = plot_unit_responses(VR,sig_units,'grat','post');
    title(T,['Post Grat Stim: ' num2str(sum(sig_units)) ' sig units']);
    subtitle(T,['Class = black, ','Inv = red, ','FF = blue']);
    if opt.save_indv_fig == true
        save_all_figures(FolderPath,'Grat_post');
        close all
    end
    
    % plot unit preVpost
    % Select units to be included in further analysis
    nat_units = VR.nat.sig_response{1} | VR.nat.sig_response{2}; % units that are sig for nat stim either pre or post
    pre_grat_units = VR.grat.sig_response{1}(:,1) & VR.grat.sig_response{1}(:,2) & VR.grat.sig_response{1}(:,3); % units that are sig for class, inv and ff stimtypes
    post_grat_units = VR.grat.sig_response{2}(:,1) & VR.grat.sig_response{2}(:,2) & VR.grat.sig_response{2}(:,3);
    grat_units = pre_grat_units | post_grat_units; % units that are sig for all_grat either pre or post
    disp(['Num of units included: ' num2str(sum(nat_units)) ' nat units & ' num2str(sum(grat_units)) ' grat_units']);
    
    disp('Plotting sig unit preVpost responses...');
    clusters = VR.clusteridx(nat_units);
    for clu = 1:numel(clusters)
        plot_unit_preVpost(clusters(clu),VR);
        if opt.save_indv_fig == true
            savefig([nat_path 'Unit_' num2str(clusters(clu)) '.fig']);
            close all
        end
    end
    
    clusters = VR.clusteridx(grat_units);
    for clu = 1:numel(clusters)
        plot_unit_preVpost(clusters(clu),VR);
        if opt.save_indv_fig == true
            savefig([grat_path 'Unit_' num2str(clusters(clu)) '.fig']);
            close all
        end
    end

end


    