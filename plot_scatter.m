function plot_scatter(xdata, ydata, marker_colour, markerstyle)
plot(xdata,ydata,markerstyle,'Color',marker_colour);
hline = refline(1,0); hline.Color = [0.3 0.3 0.3]; hline.LineStyle = '--';
hold off; box off; axis square;
end