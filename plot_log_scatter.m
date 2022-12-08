function h = plot_log_scatter(xdata, ydata, marker_colour, markerstyle)
h = loglog(xdata,ydata,markerstyle,'Color',marker_colour);
hline = refline(1,0); hline.Color = [0.3 0.3 0.3]; hline.LineStyle = '--';
xlim([10^-2 10^2]); ylim([10^-2 10^2]);
hold off; box off; axis square;
end