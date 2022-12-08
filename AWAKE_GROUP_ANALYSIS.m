% load db struct
addpath('X:\cortical_dynamics\Shared\Code\matlib\stats');
addpath('X:\cortical_dynamics\User\ms1121\Code\General\');
run('makedb_TCB2_MS'); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% TEMP MEASURES FOR ANALYSIS
con_exp = []; tcb_exp = [];
for exp = AwakeV1
    if strcmp(db(exp).syringe_contents,'CONTROL')
        con_exp = [con_exp exp];
    elseif strcmp(db(exp).syringe_contents,'TCB2')
        tcb_exp = [tcb_exp exp];
    else
        disp(['Exp: ' num2str(exp) ' missing solution'])
    end
end

con_exp = [183 184 191 193 195 199 213 220]; 
tcb_exp = [182 185 189 192 197 200 215 222];

%%
% set parameters
conditions = {'pre','post'};

% load VR for all exp
i = 1;
for exp = con_exp
   [VR_con(i)] = load_VR('X:',db,exp);
    disp(['VR loaded for exp: ' num2str(exp)]);
    i = i + 1;
end

i = 1;
for exp = tcb_exp
   [VR_tcb(i)] = load_VR('X:',db,exp);
    disp(['VR loaded for exp: ' num2str(exp)]);
    i = i + 1;
end

%% extract and concantenate unit responses from all exp
[CON.nat] = group_unit_responses(VR_con,'nat');
[CON.grat] = group_unit_responses(VR_con,'grat');
[TCB.nat] = group_unit_responses(VR_tcb,'nat');
[TCB.grat] = group_unit_responses(VR_tcb,'grat');

% find response dynamics
for cond = 1:2
    [CON.nat.resp_delay(cond).type{1}, CON.nat.rise_time(cond).type{1}] = find_response_dynamics(CON.nat.psth(cond).type{1},CON.nat.buffer,CON.nat.stim);
    [TCB.nat.resp_delay(cond).type{1}, TCB.nat.rise_time(cond).type{1}] = find_response_dynamics(TCB.nat.psth(cond).type{1},TCB.nat.buffer,TCB.nat.stim);
    for t = 1:numel(CON.grat.stimtype)
        [CON.grat.resp_delay(cond).type{t}, CON.grat.rise_time(cond).type{t}] = find_response_dynamics(CON.grat.psth(cond).type{t},CON.grat.buffer,CON.grat.stim);
        [TCB.grat.resp_delay(cond).type{t}, TCB.grat.rise_time(cond).type{t}] = find_response_dynamics(TCB.grat.psth(cond).type{t},TCB.grat.buffer,TCB.grat.stim);
    end
end


%% Set up figure
figure
tiledlayout(1,3);
set(gcf,'Color','w');

% plot headtwitches
nexttile
plot_headtwitches(db,con_exp,tcb_exp);

% plot bar chart of numbers of sig units
nexttile
plot_bar_sig_units(CON); title('Control');
nexttile
plot_bar_sig_units(TCB); title('TCB-2','color','r');


%% Plot spont Vs evoked preVpost 
% set up figure
figure
T = tiledlayout(3,4);
title(T,'Control','Color','k');
set(gcf,'Color','w');

% plot spont Vs evoked for pre and post for control
plot_spontVevoked_preVpost(CON,''); % makes 4 figures for 4 stim
plot_cdf_resp_preVpost(CON,'','k'); % makes 4 figures for 4 stim
plot_gamma_resp_preVpost(CON,'','k'); % makes 4 figures for 4 stim

% set up figure
figure
T = tiledlayout(3,4);
title(T,'TCB-2','Color','r');
set(gcf,'Color','w');

% plot spont Vs evoked for pre and post for tcb2
plot_spontVevoked_preVpost(TCB,'');
plot_cdf_resp_preVpost(TCB,'','r'); 
plot_gamma_resp_preVpost(TCB,'','r');

%% Plot response dynamics
figure
T = tiledlayout(2,4);
set(gcf,'color','w');

% plot control response dynamics
nexttile
plot_scatter(CON.grat.resp_delay(1).type{1}(CON.grat.sig_units),CON.grat.resp_delay(1).type{2}(CON.grat.sig_units),[0.5 0.5 0.5], '.'); 
hold on; plot_log_scatter(CON.grat.resp_delay(2).type{1}(CON.grat.sig_units),CON.grat.resp_delay(2).type{2}(CON.grat.sig_units),'k', '.'); 
xlabel('Class Resp Delay (ms)'); ylabel('Inv Resp Delay (ms)'); title('Control');
nexttile
plot_scatter(CON.grat.rise_time(1).type{1}(CON.grat.sig_units),CON.grat.rise_time(1).type{2}(CON.grat.sig_units),[0.5 0.5 0.5], '.'); 
hold on; plot_scatter(CON.grat.rise_time(2).type{1}(CON.grat.sig_units),CON.grat.rise_time(2).type{2}(CON.grat.sig_units),'k', '.'); 
xlabel('Class Rise Time (ms)'); ylabel('Inv Rise Time (ms)'); title('Control');
nexttile
plot_scatter(TCB.grat.resp_delay(1).type{1}(TCB.grat.sig_units),TCB.grat.resp_delay(1).type{2}(TCB.grat.sig_units),[0.5 0.5 0.5], '.'); 
hold on; plot_log_scatter(TCB.grat.resp_delay(2).type{1}(TCB.grat.sig_units),TCB.grat.resp_delay(2).type{2}(TCB.grat.sig_units),'k', '.'); 
xlabel('Class Resp Delay (ms)'); ylabel('Inv Resp Delay (ms)'); title('TCB-2','color','r');
nexttile
plot_scatter(TCB.grat.rise_time(1).type{1}(TCB.grat.sig_units),TCB.grat.rise_time(1).type{2}(TCB.grat.sig_units),[0.5 0.5 0.5], '.'); 
hold on; plot_scatter(TCB.grat.rise_time(2).type{1}(TCB.grat.sig_units),TCB.grat.rise_time(2).type{2}(TCB.grat.sig_units),'k', '.'); 
xlabel('Class Rise Time (ms)'); ylabel('Inv Rise Time (ms)'); title('TCB-2','color','r');

nexttile
plot_bar_classVinv_preVpost(CON.grat.resp_delay,CON.grat.sig_units); 
ylabel('Resp Delay (ms)'); title('Control');
nexttile
plot_bar_classVinv_preVpost(CON.grat.rise_time,CON.grat.sig_units); 
ylabel('Rise Time (ms)'); title('Control');
nexttile
plot_bar_classVinv_preVpost(TCB.grat.resp_delay,TCB.grat.sig_units); 
ylabel('Resp Delay (ms)'); title('TCB-2','color','r');
nexttile
plot_bar_classVinv_preVpost(TCB.grat.rise_time,TCB.grat.sig_units); 
ylabel('Rise Time (ms)'); title('TCB-2','color','r');

%%
figure
tiledlayout('flow');
set(gcf,'color','w');

nexttile
plot_change_classVinv(CON.grat.resp_delay,CON.grat.sig_units,TCB.grat.resp_delay,TCB.grat.sig_units);
ylabel('Change in Resp Delay (ms)');
nexttile
plot_change_classVinv(CON.grat.rise_time,CON.grat.sig_units,TCB.grat.rise_time,TCB.grat.sig_units);
ylabel('Change in Rise Time (ms)');

%%
function plot_change_classVinv(con_response_type,con_sig_units,tcb_response_type,tcb_sig_units)
for t = 1:2
    change_response_type = con_response_type(2).type{t}-con_response_type(1).type{t};
    CON_M_resp_delay(t) = mean(change_response_type(con_sig_units),'omitnan');
    CON_SEM_resp_delay(t) = std(change_response_type(con_sig_units),'omitnan')./sqrt(size(con_response_type(1).type{t}(con_sig_units),1));
end
for t = 1:2
    change_response_type = tcb_response_type(2).type{t}-tcb_response_type(1).type{t};
    TCB_M_resp_delay(t) = mean(change_response_type(tcb_sig_units),'omitnan');
    TCB_SEM_resp_delay(t) = std(change_response_type(tcb_sig_units),'omitnan')./sqrt(size(tcb_response_type(1).type{t}(tcb_sig_units),1));
end
    M_resp_delay = [CON_M_resp_delay; TCB_M_resp_delay];
    SEM_resp_delay = [CON_SEM_resp_delay; TCB_SEM_resp_delay];
    b = bar(M_resp_delay); xticklabels({'Control' 'TCB-2'});
    b(1).FaceColor = [0.3 0.3 0.3]; b(2).FaceColor = 'r';
    hold on; [ngroups,nbars] = size(M_resp_delay); x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i,:) = b(i).XEndPoints;
    end
    errorbar(x',M_resp_delay,SEM_resp_delay,'k','linestyle','none'); hold off;
    legend({'class' 'inv'},'location','north','orientation','horizontal'); legend box off;
    axis square; box off;
end

%% Local Functions
function plot_bar_sig_units(GROUP)
    num_stim = (numel(GROUP.nat.stimtype) + numel(GROUP.grat.stimtype));
    cond_num_units = NaN(num_stim,2);
    for cond = 1:2
        cond_num_units(1,cond) = sum(GROUP.nat.stim_sig_response(cond).type{1}); 
        for stim = 2:num_stim
            cond_num_units(stim,cond) = sum(GROUP.grat.stim_sig_response(cond).type{stim-1});
        end
    end
    x = categorical({'Nat','Class','Inv','FF'}); x = reordercats(x,{'Nat','Class','Inv','FF'});
    b = bar(x,cond_num_units);
    ylabel('Num Sig Units'); legend({'Pre','Post'},'interpreter','None'); legend box off;
    box off; axis square;
end

function plot_spontVevoked_preVpost(GROUP,group_name)
    nexttile
    plot_log_scatter(GROUP.nat.spont(1).type{1}(GROUP.nat.sig_units),GROUP.nat.evoked(1).type{1}(GROUP.nat.sig_units),[0.5 0.5 0.5],GROUP.nat.marker{1}); hold on;
    plot_log_scatter(GROUP.nat.spont(2).type{1}(GROUP.nat.sig_units),GROUP.nat.evoked(2).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1}, GROUP.nat.marker{1}); hold off;
    xlabel('Spontaneous FR'); ylabel('Evoked FR'); title([group_name ' N = ' num2str(sum(GROUP.nat.sig_units))]);
    for t = 1:numel(GROUP.grat.stimtype)
        nexttile
        plot_log_scatter(GROUP.grat.spont(1).type{t}(GROUP.grat.sig_units),GROUP.grat.evoked(1).type{t}(GROUP.grat.sig_units),[0.5 0.5 0.5], GROUP.grat.marker{t});
        hold on;
        plot_log_scatter(GROUP.grat.spont(2).type{t}(GROUP.grat.sig_units),GROUP.grat.evoked(2).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t},GROUP.grat.marker{t}); hold off;
        xlabel('Spontaneous FR'); ylabel('Evoked FR'); title([group_name ' N = ' num2str(sum(GROUP.grat.sig_units))]);
    end
end

function plot_cdf_resp_preVpost(GROUP,group_name,group_colour)
    nexttile
    plot_cumulative_dist(GROUP.nat.resp(1).type{1}(GROUP.nat.sig_units),[0.5 0.5 0.5],'--'); hold on;
    plot_cumulative_dist(GROUP.nat.resp(2).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1},'-');
    xlabel('Resp (E/S)');title(group_name,'color',group_colour);
    for t = 1:3
        nexttile
        plot_cumulative_dist(GROUP.grat.resp(1).type{t}(GROUP.grat.sig_units),[0.5 0.5 0.5],'--'); hold on;
        plot_cumulative_dist(GROUP.grat.resp(2).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t},'-');
        xlabel('Resp (E/S)');title(group_name,'color',group_colour);
    end
end

function plot_gamma_resp_preVpost(GROUP,group_name,group_colour)
    axes = nexttile;
    plot_gamma_dist(GROUP.nat.evoked(1).type{1}(GROUP.nat.sig_units),[0.5 0.5 0.5],'--'); hold on;
    plot_gamma_dist(GROUP.nat.evoked(2).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1},'-');
    xlabel('Evoked FR'); title(group_name,'color',group_colour);
    for t = 1:3
        ax1 = nexttile;
        plot_gamma_dist(GROUP.grat.evoked(1).type{t}(GROUP.grat.sig_units),[0.5 0.5 0.5],'--'); hold on;
        plot_gamma_dist(GROUP.grat.evoked(2).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t},'-');
        xlabel('Evoked FR'); title(group_name,'color',group_colour);
        axes = [axes ax1];
    end
    linkaxes(axes,'y');
end


function plot_cumulative_dist(FR,marker_colour,marker_style)
f = cdfplot(FR);
f.Color = marker_colour; f.LineStyle = marker_style;
ylabel('Cumulative Probability'); title('');
set(gca,'Xscale','log');
xlim([10^-2 10^2]);
grid off
box off
axis square
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 1.0;
end
end

function plot_gamma_dist(FR,marker_colour,marker_style)
e = [-3:0.02:2];
FR_params = fitdist(FR, 'Gamma');
plot(e, log(10)*logammaPDF(FR_params.b, FR_params.a,e*log(10)),marker_style,'Color', marker_colour, 'LineWidth', 1); % logammaPDF gives natural log, need log(10)*logammaPDF) to convert to log10
ylabel('Probability')
xlim([-2 2])
box off
axis square
end

function plot_bar_classVinv_preVpost(response_type,sig_units)
    for cond = 1:2
        for t = 1:2
            M_resp_delay(cond,t) = mean(response_type(cond).type{t}(sig_units),'omitnan');
            SEM_resp_delay(cond,t) = std(response_type(cond).type{t}(sig_units),'omitnan')/sqrt(size(response_type(cond).type{t}(sig_units),1));
        end
    end
    b = bar(M_resp_delay); xticklabels({'Pre' 'Post'});
    b(1).FaceColor = [0.3 0.3 0.3]; b(2).FaceColor = 'r';
    hold on; [ngroups,nbars] = size(M_resp_delay); x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i,:) = b(i).XEndPoints;
    end
    errorbar(x',M_resp_delay,SEM_resp_delay,'k','linestyle','none'); hold off;
    legend({'class' 'inv'},'location','north','orientation','horizontal'); legend box off;
    axis square; box off;
end
