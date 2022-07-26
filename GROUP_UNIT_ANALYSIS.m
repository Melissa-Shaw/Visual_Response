% load db struct
run('X:\cortical_dynamics\User\ms1121\Code\General\makedb_TCB2_MS'); % get db struct
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
T = tiledlayout(2,2);

% plot bar chart of numbers of sig units
nexttile(1) % control
grat_num_units = [sum(CON.grat(1).stim_sig_units); sum(CON.grat(2).stim_sig_units)]';
cond_num_units = [sum(CON.nat(1).sig_units) sum(CON.nat(2).sig_units); sum(CON.grat(1).sig_units) sum(CON.grat(2).sig_units); grat_num_units];
x = categorical({'Nat','All Grat','Class','Inv','FF'}); x = reordercats(x,{'Nat','All Grat','Class','Inv','FF'});
b = bar(x,cond_num_units);
ylabel('Num Sig Units'); legend({'Pre','Post'},'interpreter','None');
title('Control');

nexttile(2) % tcb
grat_num_units = [sum(TCB.grat(1).stim_sig_units); sum(TCB.grat(2).stim_sig_units)]';
cond_num_units = [sum(TCB.nat(1).sig_units) sum(TCB.nat(2).sig_units); sum(TCB.grat(1).sig_units) sum(TCB.grat(2).sig_units); grat_num_units];
x = categorical({'Nat','All Grat','Class','Inv','FF'}); x = reordercats(x,{'Nat','All Grat','Class','Inv','FF'});
b = bar(x,cond_num_units);
ylabel('Num Sig Units'); legend({'Pre','Post'},'interpreter','None');
title('TCB-2');

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
ylabel('Number of sig units');
title('Control');

nexttile(4)
pre_sig_units = []; % tcb
post_sig_units = [];
for i = 1:numel(VR_tcb)
    pre_sig_units = [pre_sig_units; sum(VR_tcb(i).nat.sig_response{1}) sum(sum(VR_tcb(i).grat.sig_response{1},2) == 3) sum(VR_tcb(i).grat.sig_response{1},1)];
    post_sig_units = [post_sig_units; sum(VR_tcb(i).nat.sig_response{2}) sum(sum(VR_tcb(i).grat.sig_response{2},2) == 3) sum(VR_tcb(i).grat.sig_response{2},1)];
end
box_colours = [0 1 0;1 1 0;0 0 0;1 0 0;0 0 1];
boxplotGroup({pre_sig_units post_sig_units},'primaryLabels',{'Pre','Post'},'Colors',box_colours,'GroupType','withinGroups');
ylabel('Number of sig units');
title('TCB-2');

% Select units to be included in further analysis
CON.nat_units = CON.nat(1).sig_units | CON.nat(2).sig_units;
CON.grat_units = CON.grat(1).sig_units | CON.grat(2).sig_units;
disp(['Control - Num units included: ' num2str(sum(CON.nat_units)) ' nat units & ' num2str(sum(CON.grat_units)) ' grat_units']);

TCB.nat_units = TCB.nat(1).sig_units | TCB.nat(2).sig_units;
TCB.grat_units = TCB.grat(1).sig_units | TCB.grat(2).sig_units;
disp(['TCB2 - Num units included: ' num2str(sum(TCB.nat_units)) ' nat units & ' num2str(sum(TCB.grat_units)) ' grat units']);

