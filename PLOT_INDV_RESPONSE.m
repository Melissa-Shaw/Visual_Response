%% Script to plot and save unit psth responses and raster for all stimulus types of all significant neurons.

%% Set up
shared_drive = 'X:';
addpath([shared_drive '\cortical_dynamics\User\ms1121\Code\General']);

% load db struct
run('makedb_TCB2_MS'); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% set script options - TEMP MEASURE TO MAKE SCRIPT FLEXIBLE WHILE CODING
opt.save_indv_fig = true;


for exp = [AnaesV1 AwakeV1]

    % load VR
    [VR] = load_VR('X:',db,exp);
    
    % set up save folder if required
    if opt.save_indv_fig == true
        close all % close all other open figures
        FolderPath = [shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_Unit_Figures'];
        mkdir(FolderPath);
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
    
end


    