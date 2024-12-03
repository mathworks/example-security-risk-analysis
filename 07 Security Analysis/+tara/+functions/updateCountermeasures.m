function nup = updateCountermeasures(sheet)
% This function collects information into the "countermeasures" sheet (SFA)
% from the linked security goals
%
% Copyright 2023-2024, The MathWorks, Inc.
    nup = updateSheet(sheet);
    disp(['Completed update: ' num2str(nup) ' countermeasures updated'])
end

function n_upd = updateSheet(sheet)
    % update all columns related to risk, based on the linked sheets
    n_upd = 0;
    thisSheet = sam.SheetWrapper(sheet);
    for rowIndex = 1:sheet.Rows
        cell_goals  = thisSheet.Cell(rowIndex,"LinkedGoals");

        %% write summary of linked goals into sheet
        [linkText, ~] = sam.describeLinks(cell_goals.getLinks, withArtifact=false);
        cell_goals.Value = sam.itemizeText(linkText);
    end
end