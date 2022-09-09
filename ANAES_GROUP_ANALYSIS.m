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


%% LOCAL FUNCTIONS
function plot_log_scatter(xdata, ydata, markerstyle)
loglog(xdata,ydata,markerstyle);
hline = refline(1,0); hline.Color = [0.3 0.3 0.3]; hline.LineStyle = '--';
xlim([10^-2 10^2]); ylim([10^-2 10^2]);
hold off; box off; axis square;
end