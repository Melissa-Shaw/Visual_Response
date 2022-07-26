% Function to save all open figures.
    % Inputs: 
        % FolderName --> filepath for saving location
        % fig_title --> name of saved figures
function save_all_figures(FolderName,fig_title)       
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = [fig_title '_' num2str(get(FigHandle, 'Number'))];
      set(0, 'CurrentFigure', FigHandle);
      savefig(fullfile(FolderName, [FigName '.fig']));
    end
end