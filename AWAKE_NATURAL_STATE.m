% load db struct
addpath('X:\cortical_dynamics\Shared\Code\matlib\stats');
addpath('X:\cortical_dynamics\User\ms1121\Code\General\');
run('makedb_TCB2_MS'); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% TEMP MEASURES FOR ANALYSIS
con_exp = [];
tcb_exp = [];
for exp = AwakeV1
    if strcmp(db(exp).syringe_contents,'CONTROL')
        con_exp = [con_exp exp];
    else
        tcb_exp = [tcb_exp exp];
    end
end

% set parameters
%con_exp = [183 184 191 193 195 199 213 220];
%tcb_exp = [182 185 189 192 197 200 215 222];
%tcb_exp = [180 189 192 215 222];
cond = 1;

% load VR for all exp
i = 1;
for exp = con_exp
   [VR_con(i)] = load_VR('X:',db,exp);
    disp(['VR loaded for exp: ' num2str(exp)]);
    i = i + 1;
end

%% extract and concantenate unit responses from all exp
[CON.nat] = group_unit_responses(VR_con,'nat');
[CON.grat] = group_unit_responses(VR_con,'grat');

% find response dynamics
[CON.nat.resp_delay(cond).type{1}, CON.nat.rise_time(cond).type{1}] = find_response_dynamics(CON.nat.psth(cond).type{1},CON.nat.buffer,CON.nat.stim);
for t = 1:numel(CON.grat.stimtype)
    [CON.grat.resp_delay(cond).type{t}, CON.grat.rise_time(cond).type{t}] = find_response_dynamics(CON.grat.psth(cond).type{t},CON.grat.buffer,CON.grat.stim);
end

% override significant units to only be pre sig units
CON.nat.sig_units = logical(CON.nat.stim_sig_response(cond).type{1}) & CON.grat.stim_sig_response(cond).type{1} & CON.grat.stim_sig_response(cond).type{2};
%CON.grat.sig_units = CON.grat.stim_sig_response(cond).type{1} & CON.grat.stim_sig_response(cond).type{2};
CON.grat.sig_units = CON.nat.sig_units;



%% Set up figure
% check significance between groups
[p_resp] = statistical_resp_test(CON,cond);
%c_resp = multcompare(stats_resp);
[p_evoked] = statistical_evoked_test(CON,cond);
%c_evoked = multcompare(stats_evoked);
%%
figure
deep_count = 0; shallow_count = 0;
for n = 1:size(CON.nat.location,1)
    if CON.nat.sig_units(n) == 1
        if CON.nat.location{n}(9:12) == 'deep'
            deep_count = deep_count + 1;
        elseif CON.nat.location{n}(9:15) == 'shallow'
            shallow_count = shallow_count + 1;
        end
    end
end
bar([shallow_count deep_count]); xticklabels({'Shallow (180-540um)' 'Deep (540-900)'});
%%
figure
T = tiledlayout('flow');
set(gcf,'Color','w');

% plot bar chart of numbers of sig units
nexttile
plot_bar_sig_units(CON,cond);

% plot spont Vs evoked for pre and post for control
plot_spontVevoked_preVpost(CON,'',cond); 
nexttile
plot_cdf_resp_preVpost(CON,cond);
title(['p = ' num2str(p_resp)]);
nexttile
plot_cdf_evoked_preVpost(CON,cond);
title(['p = ' num2str(p_evoked)]);

nexttile
plot_gamma_evoked_preVpost(CON,cond); 

% plot control response dynamics
nexttile
plot_scatter(CON.grat.resp_delay(cond).type{1}(CON.grat.sig_units),CON.grat.resp_delay(cond).type{2}(CON.grat.sig_units),'k', '.'); 
xlabel('Class Resp Delay (ms)'); ylabel('Inv Resp Delay (ms)');
nexttile
plot_scatter(CON.grat.rise_time(cond).type{1}(CON.grat.sig_units),CON.grat.rise_time(cond).type{2}(CON.grat.sig_units),'k', '.'); 
xlabel('Class Rise Time (ms)'); ylabel('Inv Rise Time (ms)');


nexttile
plot_bar_classVinv_preVpost(CON.grat.resp_delay,CON.grat.sig_units,cond); 
ylabel('Resp Delay (ms)');
p = signrank(CON.grat.resp_delay(cond).type{1}(CON.grat.sig_units),CON.grat.resp_delay(cond).type{2}(CON.grat.sig_units));
title(['p = ' num2str(p)]);
nexttile
plot_bar_classVinv_preVpost(CON.grat.rise_time,CON.grat.sig_units,cond); 
ylabel('Rise Time (ms)');
p = signrank(CON.grat.rise_time(cond).type{1}(CON.grat.sig_units),CON.grat.rise_time(cond).type{2}(CON.grat.sig_units));
title(['p = ' num2str(p)]);


%% Local Functions
function plot_bar_sig_units(GROUP,cond)
    num_stim = (numel(GROUP.nat.stimtype) + numel(GROUP.grat.stimtype));
    cond_num_units = NaN(num_stim,2);
    cond_num_units(1,cond) = sum(GROUP.nat.stim_sig_response(cond).type{1}); 
    for stim = 2:num_stim
        cond_num_units(stim,cond) = sum(GROUP.grat.stim_sig_response(cond).type{stim-1});
    end
    x = categorical({'Nat','Class','Inv','FF'}); x = reordercats(x,{'Nat','Class','Inv','FF'});
    b = bar(x,cond_num_units);
    ylabel('Num Sig Units'); %legend({'Pre','Post'},'interpreter','None'); legend box off;
    box off; axis square;
end

function plot_spontVevoked_preVpost(GROUP,group_name,cond)
    nexttile
    plot_log_scatter(GROUP.nat.spont(cond).type{1}(GROUP.nat.sig_units),GROUP.nat.evoked(cond).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1},GROUP.nat.marker{1});
    p = signrank(log10(GROUP.nat.spont(cond).type{1}(GROUP.nat.sig_units)),log10(GROUP.nat.evoked(cond).type{1}(GROUP.nat.sig_units)));
    xlabel('Spontaneous FR'); ylabel('Evoked FR'); title([group_name ' N = ' num2str(sum(GROUP.nat.sig_units)) ' p = ' num2str(p)]);
    for t = 1:numel(GROUP.grat.stimtype)
        nexttile
        plot_log_scatter(GROUP.grat.spont(cond).type{t}(GROUP.grat.sig_units),GROUP.grat.evoked(cond).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t}, GROUP.grat.marker{t});
        p = signrank(log10(GROUP.grat.spont(cond).type{t}(GROUP.grat.sig_units)),log10(GROUP.grat.evoked(cond).type{t}(GROUP.grat.sig_units)));
        xlabel('Spontaneous FR'); ylabel('Evoked FR'); title([group_name ' N = ' num2str(sum(GROUP.grat.sig_units)) ' p = ' num2str(p)]);
    end
end

function [p] = statistical_resp_test(GROUP,cond)
    disp('Resp (log(E/S)) Kruskal Wallis');
    resp = log10(GROUP.nat.resp(cond).type{1}(GROUP.grat.sig_units)); % selecting only grat units so arrays are equal
    for t = 1:3
        resp = [resp log10(GROUP.grat.resp(cond).type{t}(GROUP.grat.sig_units))];
    end
    p = kruskalwallis(resp,{'Nat' 'Class' 'Inv' 'FF'});
    %[p,tbl,stats] = friedman(resp,1);
end

function [p] = statistical_evoked_test(GROUP,cond)
    disp('Evoked (logFR) Kruskal Wallis');
    resp = log10(GROUP.nat.evoked(cond).type{1}(GROUP.grat.sig_units));
    for t = 1:3
        resp = [resp log10(GROUP.grat.evoked(cond).type{t}(GROUP.grat.sig_units))];
    end
    p = kruskalwallis(resp,{'Nat' 'Class' 'Inv' 'FF'},'off');
    %[p,tbl,stats] = friedman(resp,1);
end

function plot_cdf_resp_preVpost(GROUP,cond)
    plot_cumulative_dist(GROUP.nat.resp(cond).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1},'-');
    hold on
    for t = 1:3
        plot_cumulative_dist(GROUP.grat.resp(cond).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t},'-');
    end
    legend({'Nat','Class','Inv','FF'},'Location','northwest'); legend box off;
    xlabel('Resp (log(E/S))');
end

function plot_cdf_evoked_preVpost(GROUP,cond)
    plot_cumulative_dist(GROUP.nat.evoked(cond).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1},'-');
    hold on
    for t = 1:3
        plot_cumulative_dist(GROUP.grat.evoked(cond).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t},'-');
    end
    legend({'Nat','Class','Inv','FF'},'Location','northwest'); legend box off;
    xlabel('Evoked FR');
end

function plot_gamma_evoked_preVpost(GROUP,cond)
    plot_gamma_dist(GROUP.nat.evoked(cond).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1},'-');
    hold on
    for t = 1:3
        plot_gamma_dist(GROUP.grat.evoked(cond).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t},'-');
    end
    legend({'Nat','Class','Inv','FF'},'Location','northwest'); legend box off;
    xlabel('Evoked FR');
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

function plot_bar_classVinv_preVpost(response_type,sig_units,cond)
    for t = 1:2
        M_resp_delay(t) = mean(response_type(cond).type{t}(sig_units),'omitnan');
        SEM_resp_delay(t) = std(response_type(cond).type{t}(sig_units),'omitnan')/sqrt(size(response_type(cond).type{t}(sig_units),1));
    end
    b = bar(M_resp_delay); xticklabels({'Class' 'Inv'});
    %b.FaceColor = 'flat';
    %b.CData(1,:) = 'k'; b.CData(2,:) = 'r';
    hold on;
    errorbar([1,2],M_resp_delay,SEM_resp_delay,'k','linestyle','none'); hold off;
    axis square; box off;
end
