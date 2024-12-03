function nbad = validateCountermeasures(sheet)
% This script runs validation checks on the countermeasures sheet.
% Copyright 2023-2024, The MathWorks, Inc.
nok = validateSheet(sheet);
nbad = sheet.Rows - nok;
disp(['Completed checks: ' num2str(nok) ' entries okay, ' num2str(nbad) ' incomplete'])
end

function n_ok = validateSheet(sheet)
    n_ok = 0;
    thisSheet = sam.SheetWrapper(sheet);
    for rowIndex = 1:sheet.Rows
        oldflags = getFlags(sheet);
        thisRow = sheet.getRow(rowIndex);
        cell_ok = thisSheet.Cell(rowIndex,"OK?");
        cell_sumry = thisSheet.Cell(rowIndex,"Summary");
        cell_goals = thisSheet.Cell(rowIndex,"LinkedGoals");

        %% flag missing links to other sheets
        sam.addFlagCellNotLinkedWithSheet({thisRow}, {"threats"}, {"Row should link to sheet 'threats'"} ,"warning")
        sam.addFlagCellNotLinkedWithReq({cell_goals}, {"Should be linked to a requirement"} ,"error")

        %% flag empty cells
        sfaTemplate.AddFlagEmptyCell({cell_sumry},{"Must not be empty"},"error");

        %% No flags == "complete", otherwise the highest flag in row
        [~, highestFlag] = sam.countFlagTypes(sheet, oldflags);
        if isempty(highestFlag)
            addFlag(cell_ok, "check", description="Complete");
            n_ok = n_ok + 1;
        else
            addFlag(cell_ok, highestFlag, description="Incomplete");
        end
    end
end