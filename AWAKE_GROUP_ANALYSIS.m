% load db struct
addpath('X:\cortical_dynamics\User\ms1121\Code\General\');
run('makedb_TCB2_MS'); % get db struct
clear Batch1PFC Batch2PFC Batch3PFC AnaesPFC % clear unnecessary exp groups

% TEMP MEASURES FOR ANALYSIS
AwakeV1 = [AwakeV1]; % TEMP TO EXCLUDE NP1 RECORDINGS AND NEW RECORDINGS
AwakeV1_Solution = {'C' 'T' 'T' 'C' 'T' 'C' 'C' 'T' 'C' 'T' 'T' 'C' 'C' 'T' 'C' 'T' 'T' 'C'}; % BASED ON HTR AND LFP
con_exp = strcmp(AwakeV1_Solution,'C');
tcb_exp = strcmp(AwakeV1_Solution,'T');

% set parameters
conditions = {'pre','post'};
nat_colour = {'g'};
grat_colour = {'k','r','b'};

% load VR for all exp
i = 1;
for exp = [AwakeV1(con_exp)]
   [VR_con(i)] = load_VR('X:',db,exp);
    disp(['VR loaded for exp: ' num2str(exp)]);
    i = i + 1;
end

i = 1;
for exp = [AwakeV1(tcb_exp)]
   [VR_tcb(i)] = load_VR('X:',db,exp);
    disp(['VR loaded for exp: ' num2str(exp)]);
    i = i + 1;
end

% extract and concantenate unit responses from all exp
[CON.nat,CON.grat] = group_unit_responses(VR_con);
[TCB.nat,TCB.grat] = group_unit_responses(VR_tcb);

%% Set up figure
figure
tiledlayout(2,2);
set(gcf,'Color','w');

% plot bar chart of numbers of sig units
nexttile(1) % control
grat_num_units = [sum(CON.grat(1).stim_sig_units); sum(CON.grat(2).stim_sig_units)]';
cond_num_units = [sum(CON.nat(1).sig_units) sum(CON.nat(2).sig_units); sum(CON.grat(1).sig_units) sum(CON.grat(2).sig_units); grat_num_units];
x = categorical({'Nat','All Grat','Class','Inv','FF'}); x = reordercats(x,{'Nat','All Grat','Class','Inv','FF'});
b = bar(x,cond_num_units);
ylabel('Num Sig Units'); legend({'Pre','Post'},'interpreter','None'); title('Control');
box off; axis square;

nexttile(2) % tcb
grat_num_units = [sum(TCB.grat(1).stim_sig_units); sum(TCB.grat(2).stim_sig_units)]';
cond_num_units = [sum(TCB.nat(1).sig_units) sum(TCB.nat(2).sig_units); sum(TCB.grat(1).sig_units) sum(TCB.grat(2).sig_units); grat_num_units];
x = categorical({'Nat','All Grat','Class','Inv','FF'}); x = reordercats(x,{'Nat','All Grat','Class','Inv','FF'});
b = bar(x,cond_num_units);
ylabel('Num Sig Units'); legend({'Pre','Post'},'interpreter','None'); title('TCB-2','Color','r');
box off; axis square;

clear grat_num_units cond_num_units x b

% plot boxplot of numbers of sig units across recordings
nexttile(3)
pre_sig_units = []; % control
post_sig_units = [];
for i = 1:numel(VR_con)
    pre_sig_units = [pre_sig_units; sum(VR_con(i).nat.sig_response{1}) sum(sum(VR_con(i).grat.sig_response{1},2) == 3) sum(VR_con(i).grat.sig_response{1},1)];
    post_sig_units = [post_sig_units; sum(VR_con(i).nat.sig_response{2}) sum(sum(VR_con(i).grat.sig_response{2},2) == 3) sum(VR_con(i).grat.sig_response{2},1)];
end
box_colours = [0 1 0;1 1 0;0 0 0;1 0 0;0 0 1];
boxplotGroup({pre_sig_units post_sig_units},'primaryLabels',{'Pre','Post'},'Colors',box_colours,'GroupType','withinGroups');
ylabel('Number of sig units'); title('Control');
box off; axis square;

nexttile(4)
pre_sig_units = []; % tcb
post_sig_units = [];
for i = 1:numel(VR_tcb)
    pre_sig_units = [pre_sig_units; sum(VR_tcb(i).nat.sig_response{1}) sum(sum(VR_tcb(i).grat.sig_response{1},2) == 3) sum(VR_tcb(i).grat.sig_response{1},1)];
    post_sig_units = [post_sig_units; sum(VR_tcb(i).nat.sig_response{2}) sum(sum(VR_tcb(i).grat.sig_response{2},2) == 3) sum(VR_tcb(i).grat.sig_response{2},1)];
end
box_colours = [0 1 0;1 1 0;0 0 0;1 0 0;0 0 1];
boxplotGroup({pre_sig_units post_sig_units},'primaryLabels',{'Pre','Post'},'Colors',box_colours,'GroupType','withinGroups');
ylabel('Number of sig units'); title('TCB-2','Color','r');
box off; axis square;

%% Select units to be included in further analysis
CON.nat_units = CON.nat(1).sig_units | CON.nat(2).sig_units;
CON.grat_units = CON.grat(1).sig_units | CON.grat(2).sig_units;
TCB.nat_units = TCB.nat(1).sig_units | TCB.nat(2).sig_units;
TCB.grat_units = TCB.grat(1).sig_units | TCB.grat(2).sig_units;

%% Plot response amplitude preVpost
figure
tiledlayout(2,4);
set(gcf,'Color','w');

nexttile(1)
plot_log_scatter(CON.nat(1).resp_amp(CON.nat_units),CON.nat(2).resp_amp(CON.nat_units),'gx');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['CON Nat N = ' num2str(sum(CON.nat_units))]);
nexttile(2)
plot_log_scatter(CON.grat(1).resp_amp{1}(CON.grat_units),CON.grat(2).resp_amp{1}(CON.grat_units),'ko');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['CON Class N = ' num2str(sum(CON.grat_units))]);
nexttile(3)
plot_log_scatter(CON.grat(1).resp_amp{2}(CON.grat_units),CON.grat(2).resp_amp{2}(CON.grat_units),'r+');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['CON Inv N = ' num2str(sum(CON.grat_units))]);
nexttile(4)
plot_log_scatter(CON.grat(1).resp_amp{3}(CON.grat_units),CON.grat(2).resp_amp{3}(CON.grat_units),'b.');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['CON FullField N = ' num2str(sum(CON.grat_units))]);

% plot tcb2 response amplitude preVpost
nexttile(5)
plot_log_scatter(TCB.nat(1).resp_amp(TCB.nat_units),TCB.nat(2).resp_amp(TCB.nat_units),'gx');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['TCB Nat N = ' num2str(sum(TCB.nat_units))],'Color','r');
nexttile(6)
plot_log_scatter(TCB.grat(1).resp_amp{1}(TCB.grat_units),TCB.grat(2).resp_amp{1}(TCB.grat_units),'ko');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['TCB Class N = ' num2str(sum(TCB.grat_units))],'Color','r');
nexttile(7)
plot_log_scatter(TCB.grat(1).resp_amp{2}(TCB.grat_units),TCB.grat(2).resp_amp{2}(TCB.grat_units),'r+');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['TCB Inv N = ' num2str(sum(TCB.grat_units))],'Color','r');
nexttile(8)
plot_log_scatter(TCB.grat(1).resp_amp{3}(TCB.grat_units),TCB.grat(2).resp_amp{3}(TCB.grat_units),'b.');
xlabel('Resp Amp Before'); ylabel('Resp Amp After'); title(['TCB FullField N = ' num2str(sum(TCB.grat_units))],'Color','r');


%% LOCAL FUNCTIONS
function plot_log_scatter(xdata, ydata, markerstyle)
loglog(xdata,ydata,markerstyle);
hline = refline(1,0); hline.Color = [0.3 0.3 0.3]; hline.LineStyle = '--';
xlim([10^-2 10^2]); ylim([10^-2 10^2]);
hold off; box off; axis square;
end
