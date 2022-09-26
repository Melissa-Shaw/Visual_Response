function plot_log_scatter(xdata, ydata, markerstyle)
loglog(xdata,ydata,markerstyle);
hline = refline(1,0); hline.Color = [0.3 0.3 0.3]; hline.LineStyle = '--';
xlim([10^-2 10^2]); ylim([10^-2 10^2]);
hold off; box off; axis square;
end