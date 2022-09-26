% load db struct
addpath('X:\cortical_dynamics\User\ms1121\Code\General\');
run('makedb_TCB2_MS'); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% set parameters
conditions = {'pre','post'};
nat_colour = {'g'};
grat_colour = {'k','r','b'};

% load VR for all exp
i = 1;
for exp = AnaesV1
   [VR(i)] = load_VR('X:',db,exp);
    disp(['VR loaded for exp: ' num2str(exp)]);
    i = i + 1;
end

% extract and concantenate unit responses from all exp
[GROUP.nat,GROUP.grat] = group_unit_responses(VR);

%% Set up figure
figure
tiledlayout(1,2);
set(gcf,'Color','w');

% plot bar chart of numbers of sig units
nexttile(1)
grat_num_units = [sum(GROUP.grat(1).stim_sig_units); sum(GROUP.grat(2).stim_sig_units)]';
cond_num_units = [sum(GROUP.nat(1).sig_units) sum(GROUP.nat(2).sig_units); sum(GROUP.grat(1).sig_units) sum(GROUP.grat(2).sig_units); grat_num_units];
x = categorical({'Nat','All Grat','Class','Inv','FF'}); x = reordercats(x,{'Nat','All Grat','Class','Inv','FF'});
b = bar(x,cond_num_units);
ylabel('Num Sig Units'); legend({'Pre','Post'},'interpreter','None'); title('TCB-2','Color','r');
box off; axis square;

clear grat_num_units cond_num_units x b

% plot boxplot of numbers of sig units across recordings
nexttile(2)
pre_sig_units = []; % control
post_sig_units = [];
for i = 1:numel(VR)
    pre_sig_units = [pre_sig_units; sum(VR(i).nat.sig_response{1}) sum(sum(VR(i).grat.sig_response{1},2) == 3) sum(VR(i).grat.sig_response{1},1)];
    post_sig_units = [post_sig_units; sum(VR(i).nat.sig_response{2}) sum(sum(VR(i).grat.sig_response{2},2) == 3) sum(VR(i).grat.sig_response{2},1)];
end
box_colours = [0 1 0;1 1 0;0 0 0;1 0 0;0 0 1];
boxplotGroup({pre_sig_units post_sig_units},'primaryLabels',{'Pre','Post'},'Colors',box_colours,'GroupType','withinGroups');
ylabel('Number of sig units'); title('TCB-2','Color','r');
box off; axis square;


%% Select units to be included in further analysis
GROUP.nat_units = GROUP.nat(1).sig_units | GROUP.nat(2).sig_units;
GROUP.grat_units = GROUP.grat(1).sig_units | GROUP.grat(2).sig_units;

%% Plot response amplitude preVpost
figure
tiledlayout(2,4);
set(gcf,'Color','w');

nexttile(1)
plot_log_scatter(GROUP.nat(1).resp_amp(GROUP.nat_units),GROUP.nat(2).resp_amp(GROUP.nat_units),'gx');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['TCB Nat N = ' num2str(sum(GROUP.nat_units))],'Color','r');
nexttile(2)
plot_log_scatter(GROUP.grat(1).resp_amp{1}(GROUP.grat_units),GROUP.grat(2).resp_amp{1}(GROUP.grat_units),'ko');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['TCB Class N = ' num2str(sum(GROUP.grat_units))],'Color','r');
nexttile(3)
plot_log_scatter(GROUP.grat(1).resp_amp{2}(GROUP.grat_units),GROUP.grat(2).resp_amp{2}(GROUP.grat_units),'r+');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['TCB Inv N = ' num2str(sum(GROUP.grat_units))],'Color','r');
nexttile(4)
plot_log_scatter(GROUP.grat(1).resp_amp{3}(GROUP.grat_units),GROUP.grat(2).resp_amp{3}(GROUP.grat_units),'b.');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['TCB FullField N = ' num2str(sum(GROUP.grat_units))],'Color','r');

%% Plot change in response amplitude
GROUP.nat_change_resp = GROUP.nat(2).resp_amp./GROUP.nat(1).resp_amp;
for grat_stim = 1:3
    GROUP.grat_change_resp(:,grat_stim) = GROUP.grat(2).resp_amp{grat_stim}./GROUP.grat(1).resp_amp{grat_stim};
end

if size(GROUP.grat_change_resp(GROUP.grat_units,:),1) > size(GROUP.nat_change_resp(GROUP.nat_units),1)
    extra_values = NaN(size(GROUP.grat_change_resp(GROUP.grat_units,:),1) - size(GROUP.nat_change_resp(GROUP.nat_units),1),1);
    group_change_resp = [[GROUP.nat_change_resp(GROUP.nat_units); extra_values] GROUP.grat_change_resp(GROUP.grat_units,:)];
elseif size(GROUP.grat_change_resp(GROUP.grat_units,:),1) < size(GROUP.nat_change_resp(GROUP.nat_units),1)
    extra_values = NaN(size(GROUP.nat_change_resp(GROUP.nat_units),1) - size(GROUP.grat_change_resp(GROUP.grat_units,:),1),3);
    group_change_resp = [GROUP.nat_change_resp(GROUP.nat_units) [GROUP.grat_change_resp(GROUP.grat_units,:); extra_values]];
else
    group_change_resp = [GROUP.nat_change_resp(GROUP.nat_units) GROUP.grat_change_resp(GROUP.grat_units,:)];
end

figure
set(gcf,'color','w');
box_colours = [0 1 0;1 1 0;0 0 0;1 0 0;0 0 1];
b = bar(nanmedian(group_change_resp),'FaceColor','r','BaseValue',1);
xticklabels({'Nat','Class','Inv','FF'});
ylabel('Median \Delta Log Resp Amp (Post/Pre)');
box off; axis square;

%% Plot distributions of response amplitude
figure
set(gcf,'color','w');
tiledlayout(2,4)

% plot cumulative distributions
nexttile
plot_cumulative_dist(GROUP.nat(1).resp_amp(GROUP.nat_units),'g','--'); hold on;
plot_cumulative_dist(GROUP.nat(2).resp_amp(GROUP.nat_units),'g','-'); hold off;
title('TCB-2','color','r');

for grat_stim = 1:3
    nexttile
    plot_cumulative_dist(GROUP.grat(1).resp_amp{grat_stim}(GROUP.grat_units),grat_colour{grat_stim},'--'); hold on;
    plot_cumulative_dist(GROUP.grat(2).resp_amp{grat_stim}(GROUP.grat_units),grat_colour{grat_stim},'-'); hold off;
    title('TCB-2','color','r');
end

% plot log gamma distributions
nexttile
plot_gamma_dist(GROUP.nat(1).resp_amp(GROUP.nat_units),'g--'); hold on;
plot_gamma_dist(GROUP.nat(2).resp_amp(GROUP.nat_units),'g'); hold off;
title('TCB-2','color','r');

for grat_stim = 1:3
    nexttile
    plot_gamma_dist(GROUP.grat(1).resp_amp{grat_stim}(GROUP.grat_units),[grat_colour{grat_stim} '--']); hold on;
    plot_gamma_dist(GROUP.grat(2).resp_amp{grat_stim}(GROUP.grat_units),grat_colour{grat_stim}); hold off;
    title('TCB-2','color','r');
end


%% Local Functions
function plot_cumulative_dist(FR,marker_colour,marker_style)
f = cdfplot(FR);
f.Color = marker_colour; f.LineStyle = marker_style;
xlabel('Response Amp'); ylabel('Cumulative Probability'); title('');
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

function plot_gamma_dist(FR,marker_style)
e = [-3:0.02:2];
FR_params = fitdist(FR, 'Gamma');
plot(e, log(10)*logammaPDF(FR_params.b, FR_params.a,e*log(10)),marker_style,  'LineWidth', 1); % logammaPDF gives natural log, need log(10)*logammaPDF) to convert to log10
xlabel('Log Response Amplitude')
ylabel('Probability')
xlim([-2 2])
box off
axis square
end

