function [legend_array] = plot_shank_location(locations,channels,marker_style)

    % set empty vectors
    xData = NaN(numel(locations));
    yData = xData;

    % find x and y values for each unit location
    for n = 1:numel(locations) % for each unit
        if isnan(locations{n}) % NP1 recordings dont have location
            x = NaN; y = NaN;
        elseif strcmp(locations(n),'shank_1_deep')
            x = 1; y = channels(n);
        elseif strcmp(locations(n),'shank_2_deep')
            x = 2; y = channels(n) - 48;
        elseif strcmp(locations(n),'shank_3_deep')
            x = 3; y = channels(n) - 192;
        elseif strcmp(locations(n),'shank_4_deep')
            x = 4; y = channels(n) - 240;
        elseif strcmp(locations(n),'shank_1_shallow')
            x = 1; y = channels(n) - 48;
        elseif strcmp(locations(n),'shank_2_shallow')
            x = 2; y = channels(n) - 96;
        elseif strcmp(locations(n),'shank_3_shallow')
            x = 3; y = channels(n) - 240;
        elseif strcmp(locations(n),'shank_4_shallow')
            x = 4; y = channels(n) - 288;
        else
            disp(['No known location for unit: ' num2str(n)]);
        end
        xData(n) = x;
        yData(n) = y;
    end

    % plot scatter of all units
    plot(xData,yData,marker_style);
    xlabel('Shank'); xlim([0.5 4.5]);
    ylabel('Channel'); ylim([0,100]);
    legend_array = cell(1,numel(locations));
    for n = 1:numel(locations)
        legend_array{n} = '';
    end
    %title(['Num units: ' num2str(numel(locations))]);

end