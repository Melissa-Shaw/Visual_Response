%% Plot resp preVpost (evoked/spont)
figure
T = tiledlayout(2,4);
title(T,'Response (E/S)');
set(gcf,'Color','w');

nexttile
plot_log_scatter(CON.nat(1).resp(CON.nat_units),CON.nat(2).resp(CON.nat_units),nat_colour, nat_marker);
xlabel('Before'); ylabel('After'); title(['CON N = ' num2str(sum(CON.nat_units))]);
for t = 1:3
    nexttile
    plot_log_scatter(CON.grat(1).resp{t}(CON.grat_units),CON.grat(2).resp{t}(CON.grat_units),grat_colour{t}, grat_marker{t});
    xlabel('Before'); ylabel('After'); title(['CON N = ' num2str(sum(CON.grat_units))]);
end

nexttile
plot_log_scatter(TCB.nat(1).resp(TCB.nat_units),TCB.nat(2).resp(TCB.nat_units),nat_colour, nat_marker);
xlabel('Before'); ylabel('After'); title(['TCB N = ' num2str(sum(TCB.nat_units))],'color','r');
for t = 1:3
    nexttile
    plot_log_scatter(TCB.grat(1).resp{t}(TCB.grat_units),TCB.grat(2).resp{t}(TCB.grat_units),grat_colour{t}, grat_marker{t});
    xlabel('Before'); ylabel('After'); title(['TCB N = ' num2str(sum(TCB.grat_units))],'color','r');
end


%% Plot mean response ratio preVpost
figure
T = tiledlayout(1,2);
set(gcf,'Color','w');

for cond = 1:2
    CON.nat(cond).resp(CON.nat(cond).resp == Inf | CON.nat(cond).resp == -Inf) = NaN;
    TCB.nat(cond).resp(TCB.nat(cond).resp == Inf | TCB.nat(cond).resp == -Inf) = NaN;
    for t = 1:3
        CON.grat(cond).resp{t}(CON.grat(cond).resp{t} == Inf | CON.grat(cond).resp{t} == -Inf) = NaN;
        TCB.grat(cond).resp{t}(TCB.grat(cond).resp{t} == Inf | TCB.grat(cond).resp{t} == -Inf) = NaN;
    end
end

for cond = 1:2
    CON.response(cond).M_resp(1) = nanmean(CON.nat(cond).resp);
    CON.response(cond).SD_resp(1) = nanstd(CON.nat(cond).resp)./sqrt(numel(CON.nat(cond).resp));
    TCB.response(cond).M_resp(1) = nanmean(TCB.nat(cond).resp);
    TCB.response(cond).SD_resp(1) = nanstd(TCB.nat(cond).resp)./sqrt(numel(TCB.nat(cond).resp));
    for t = 1:3
        CON.response(cond).M_resp(t+1) = nanmean(CON.grat(cond).resp{t});
        CON.response(cond).SD_resp(t+1) = nanstd(CON.grat(cond).resp{t})./sqrt(numel(CON.grat(cond).resp{t}));
        TCB.response(cond).M_resp(t+1) = nanmean(TCB.grat(cond).resp{t});
        TCB.response(cond).SD_resp(t+1) = nanstd(TCB.grat(cond).resp{t})./sqrt(numel(CON.grat(cond).resp{t}));
    end
end

ax1 = nexttile;
b = bar([CON.response(1).M_resp' CON.response(2).M_resp'],'BaseValue',1);
b(1).FaceColor = 'k'; b(2).FaceColor = 'r';
xticklabels({'Nat','Class','Inv','FF'}); legend({'Before','After'},'location','best'); legend box off;
ylabel('Mean Response (E/S)');
box off; axis square; title('Control');

hold on;
for cond = 1:2
    x(cond,:) = b(cond).XEndPoints;
end
errorbar(x',[CON.response(1).M_resp' CON.response(2).M_resp'],[CON.response(1).SD_resp' CON.response(2).SD_resp'],'k','linestyle','none');
hold off;

ax2 = nexttile;
b = bar([TCB.response(1).M_resp' TCB.response(2).M_resp'],'BaseValue',1);
b(1).FaceColor = 'k'; b(2).FaceColor = 'r';
xticklabels({'Nat','Class','Inv','FF'}); legend({'Before','After'},'location','best'); legend box off;
ylabel('Mean Response (E/S)');
box off; axis square; title('TCB-2','color','r');

hold on;
for cond = 1:2
    x(cond,:) = b(cond).XEndPoints;
end
errorbar(x',[TCB.response(1).M_resp' TCB.response(2).M_resp'],[TCB.response(1).SD_resp' TCB.response(2).SD_resp'],'k','linestyle','none');
hold off;


linkaxes([ax1 ax2],'y');



%%
% plot spontaneous preVpost
figure
T = tiledlayout(2,4);
title(T,'Spontaneous');
set(gcf,'Color','w');

nexttile
plot_log_scatter(CON.nat.spont(cond).type{t}(CON.nat.sig_units),CON.nat.spont(cond).type{t}(CON.nat.sig_units),CON.nat.colour{1},CON.nat.marker{1});
xlabel('Before'); ylabel('After'); title(['CON N = ' num2str(sum(CON.nat.sig_units))]);
for t = 1:numel(CON.grat.stimtype)
    nexttile
    plot_log_scatter(CON.grat.spont(cond).type{t}(CON.grat.sig_units),CON.grat.spont(cond).type{t}(CON.grat.sig_units),CON.grat.colour{t}, CON.grat.marker{t});
    xlabel('Before'); ylabel('After'); title(['CON N = ' num2str(sum(CON.grat.sig_units))]);
end

nexttile
plot_log_scatter(TCB.nat(1).spont(TCB.nat_units),TCB.nat(2).spont(TCB.nat_units),nat_colour, nat_marker);
xlabel('Before'); ylabel('After'); title(['TCB N = ' num2str(sum(TCB.nat_units))],'color','r');
for t = 1:3
    nexttile
    plot_log_scatter(TCB.grat(1).spont{t}(TCB.grat_units),TCB.grat(2).spont{t}(TCB.grat_units),grat_colour{t}, grat_marker{t});
    xlabel('Before'); ylabel('After'); title(['TCB N = ' num2str(sum(TCB.grat_units))],'color','r');
end

%% Plot distributions of spontaneous
figure
set(gcf,'color','w');
T = tiledlayout(4,4);
title(T,'Spontaneous');

% plot CON distributions
nexttile
plot_cumulative_dist(CON.nat(1).spont(CON.nat_units),nat_colour, '--'); hold on;
plot_cumulative_dist(CON.nat(2).spont(CON.nat_units),nat_colour,'-'); hold off;
title('Control','color','k');
for t = 1:3
    nexttile
    plot_cumulative_dist(CON.grat(1).spont{t}(CON.grat_units),grat_colour{t},'--'); hold on;
    plot_cumulative_dist(CON.grat(2).spont{t}(CON.grat_units),grat_colour{t},'-'); hold off;
    title('Control','color','k');
end

nexttile
plot_gamma_dist(CON.nat(1).spont(CON.nat_units),[nat_colour '--']); hold on;
plot_gamma_dist(CON.nat(2).spont(CON.nat_units),nat_colour); hold off;
title('Control','color','k');
for t = 1:3
    nexttile
    plot_gamma_dist(CON.grat(1).spont{t}(CON.grat_units),[grat_colour{t} '--']); hold on;
    plot_gamma_dist(CON.grat(2).spont{t}(CON.grat_units),grat_colour{t}); hold off;
    title('Control','color','k');
end

% plot TCB distributions
nexttile
plot_cumulative_dist(TCB.nat(1).spont(TCB.nat_units),nat_colour,'--'); hold on;
plot_cumulative_dist(TCB.nat(2).spont(TCB.nat_units),nat_colour,'-'); hold off;
title('TCB-2','color','r');
for t = 1:3
    nexttile
    plot_cumulative_dist(TCB.grat(1).spont{t}(TCB.grat_units),grat_colour{t},'--'); hold on;
    plot_cumulative_dist(TCB.grat(2).spont{t}(TCB.grat_units),grat_colour{t},'-'); hold off;
    title('TCB-2','color','r');
end

nexttile
plot_gamma_dist(TCB.nat(1).spont(TCB.nat_units),[nat_colour '--']); hold on;
plot_gamma_dist(TCB.nat(2).spont(TCB.nat_units),nat_colour); hold off;
title('TCB-2','color','r');
for t = 1:3
    nexttile
    plot_gamma_dist(TCB.grat(1).spont{t}(TCB.grat_units),[grat_colour{t} '--']); hold on;
    plot_gamma_dist(TCB.grat(2).spont{t}(TCB.grat_units),grat_colour{t}); hold off;
    title('TCB-2','color','r');
end


%% Plot evoked preVpost
figure
T = tiledlayout(2,4);
title(T,'Evoked');
set(gcf,'Color','w');

nexttile
plot_log_scatter(CON.nat(1).evoked(CON.nat_units),CON.nat(2).evoked(CON.nat_units),nat_colour, nat_marker);
xlabel('Before'); ylabel('After'); title(['CON N = ' num2str(sum(CON.nat_units))]);
for t = 1:3
    nexttile
    plot_log_scatter(CON.grat(1).evoked{t}(CON.grat_units),CON.grat(2).evoked{t}(CON.grat_units),grat_colour{t}, grat_marker{t});
    xlabel('Before'); ylabel('After'); title(['CON N = ' num2str(sum(CON.grat_units))]);
end

nexttile
plot_log_scatter(TCB.nat(1).evoked(TCB.nat_units),TCB.nat(2).evoked(TCB.nat_units),nat_colour, nat_marker);
xlabel('Before'); ylabel('After'); title(['TCB N = ' num2str(sum(TCB.nat_units))],'color','r');
for t = 1:3
    nexttile
    plot_log_scatter(TCB.grat(1).evoked{t}(TCB.grat_units),TCB.grat(2).evoked{t}(TCB.grat_units),grat_colour{t}, grat_marker{t});
    xlabel('Before'); ylabel('After'); title(['TCB N = ' num2str(sum(TCB.grat_units))],'color','r');
end

%% Plot distributions of evoked
figure
set(gcf,'color','w');
T = tiledlayout(4,4);
title(T,'Evoked');

% plot CON distributions
nexttile
plot_cumulative_dist(CON.nat(1).evoked(CON.nat_units),nat_colour,'--'); hold on;
plot_cumulative_dist(CON.nat(2).evoked(CON.nat_units),nat_colour,'-'); hold off;
title('Control','color','k');
for t = 1:3
    nexttile
    plot_cumulative_dist(CON.grat(1).evoked{t}(CON.grat_units),grat_colour{t},'--'); hold on;
    plot_cumulative_dist(CON.grat(2).evoked{t}(CON.grat_units),grat_colour{t},'-'); hold off;
    title('Control','color','k');
end

nexttile
plot_gamma_dist(CON.nat(1).evoked(CON.nat_units),[nat_colour '--']); hold on;
plot_gamma_dist(CON.nat(2).evoked(CON.nat_units),nat_colour); hold off;
title('Control','color','k');
for t = 1:3
    nexttile
    plot_gamma_dist(CON.grat(1).evoked{t}(CON.grat_units),[grat_colour{t} '--']); hold on;
    plot_gamma_dist(CON.grat(2).evoked{t}(CON.grat_units),grat_colour{t}); hold off;
    title('Control','color','k');
end

% plot TCB distributions
nexttile
plot_cumulative_dist(TCB.nat(1).evoked(TCB.nat_units),nat_colour,'--'); hold on;
plot_cumulative_dist(TCB.nat(2).evoked(TCB.nat_units),nat_colour,'-'); hold off;
title('TCB-2','color','r');
for t = 1:3
    nexttile
    plot_cumulative_dist(TCB.grat(1).evoked{t}(TCB.grat_units),grat_colour{t},'--'); hold on;
    plot_cumulative_dist(TCB.grat(2).evoked{t}(TCB.grat_units),grat_colour{t},'-'); hold off;
    title('TCB-2','color','r');
end

nexttile
plot_gamma_dist(TCB.nat(1).evoked(TCB.nat_units),[nat_colour '--']); hold on;
plot_gamma_dist(TCB.nat(2).evoked(TCB.nat_units),nat_colour); hold off;
title('TCB-2','color','r');
for t = 1:3
    nexttile
    plot_gamma_dist(TCB.grat(1).evoked{t}(TCB.grat_units),[grat_colour{t} '--']); hold on;
    plot_gamma_dist(TCB.grat(2).evoked{t}(TCB.grat_units),grat_colour{t}); hold off;
    title('TCB-2','color','r');
end



%% Functions made

function plot_cdf_spontVevoked_preVpost(GROUP,group_name,group_colour)
    nexttile
    plot_cumulative_dist(GROUP.nat.spont(1).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1},'-'); hold on;
    plot_cumulative_dist(GROUP.nat.evoked(1).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1},'-');
    plot_cumulative_dist(GROUP.nat.spont(2).type{1}(GROUP.nat.sig_units),'m','--');
    plot_cumulative_dist(GROUP.nat.evoked(2).type{1}(GROUP.nat.sig_units),'m','-'); hold off;
    title(group_name,'color',group_colour);
    for t = 1:3
        nexttile
        plot_cumulative_dist(GROUP.grat.spont(1).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t},'--'); hold on;
        plot_cumulative_dist(GROUP.grat.evoked(1).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t},'-');
        plot_cumulative_dist(GROUP.grat.spont(2).type{t}(GROUP.grat.sig_units),'m','--');
        plot_cumulative_dist(GROUP.grat.evoked(2).type{t}(GROUP.grat.sig_units),'m','-'); hold off;
        title(group_name,'color',group_colour);
    end
end

function plot_gamma_evokedVspont_preVpost(GROUP,group_name,group_colour)
    nexttile
    plot_gamma_dist(GROUP.nat.spont(1).type{1}(GROUP.nat.sig_units),[GROUP.nat.colour{1} '--']); hold on;
    plot_gamma_dist(GROUP.nat.evoked(1).type{1}(GROUP.nat.sig_units),GROUP.nat.colour{1});
    plot_gamma_dist(GROUP.nat.spont(2).type{1}(GROUP.nat.sig_units),['m' '--']);
    plot_gamma_dist(GROUP.nat.evoked(2).type{1}(GROUP.nat.sig_units),'m'); hold off;
    title(group_name,'color',group_colour);
    for t = 1:3
        nexttile
        plot_gamma_dist(GROUP.grat.spont(1).type{t}(GROUP.grat.sig_units),[GROUP.grat.colour{t} '--']); hold on;
        plot_gamma_dist(GROUP.grat.evoked(1).type{t}(GROUP.grat.sig_units),GROUP.grat.colour{t});
        plot_gamma_dist(GROUP.grat.spont(2).type{t}(GROUP.grat.sig_units),['m' '--']);
        plot_gamma_dist(GROUP.grat.evoked(2).type{t}(GROUP.grat.sig_units),'m'); hold off;
        title(group_name,'color',group_colour);
    end
end
