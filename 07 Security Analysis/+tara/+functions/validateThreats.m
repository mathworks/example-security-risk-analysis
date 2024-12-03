function nbad = validateThreats(sheet)
% This function runs consistency checks on the "threat" sheet (SFA).
%
% The following completeness checks are provided:
%   - broken or missing links to faults and assets
%   - threat does not exceed risk acceptance threshold
%   - treatment decision is consistent with table data
%
% Copyright 2023-2024, The MathWorks, Inc.
    nok = validateSheet(sheet);
    nbad = sheet.Rows - nok;
    disp(['Completed TARA checks: ' num2str(nok) ' threats addressed, '...
          num2str(nbad) ' open'])
end

function n_ok = validateSheet(sheet)
    % runs completeness checks on the threats and creates flags
    n_ok = 0;
    thisSheet = sam.SheetWrapper(sheet);
    for rowIndex = 1:sheet.Rows
        thisRow = sheet.getRow(rowIndex);
        oldflags = getFlags(sheet);
        cell_ok = thisSheet.Cell(rowIndex,"OK?");
        cell_threat = thisSheet.Cell(rowIndex,"Summary");
        cell_lmeas  = thisSheet.Cell(rowIndex,"LinkedCountermeasures");
        cell_lfault = thisSheet.Cell(rowIndex,"LinkedFaults");
        cell_risk   = thisSheet.Cell(rowIndex,"Risk");
        cell_statu  = thisSheet.Cell(rowIndex,"Status");
        cell_scmmt  = thisSheet.Cell(rowIndex,"Comment");
        
        %% flag missing or broken links to assets or faults
        sam.addFlagCellNotLinkedWithSheet({thisRow}, {"assets"}, {"Row should link to sheet 'assets'"} ,"error")
        sam.addFlagCellNotLinkedWithSheet({cell_lfault}, {"RobotHazardAssessment"}, {} ,"error");
    
        %% flag if certain cells are empty
        sfaTemplate.AddFlagEmptyCell({cell_threat},{"Must not be empty"},"error")
    
        %% Cross-sheet consistency check of compromised properties - must match asset's
        [T, ~] = sam.lookupLinkedSheetRow(thisRow.getLinks);
        if height(T) > 0
            for propName = tara.functions.getCybersecProperties()
                cell_tprop = thisSheet.Cell(rowIndex,propName);
                threatHasProp = cell_tprop.Value;
                assetHasProp = any(cellfun(@(x) x, T.(propName)));
                if threatHasProp && ~assetHasProp
                    addFlag(cell_tprop, "warning", Description="This property does not exist in the linked asset(s)")
                end
            end
        end

        %% Consistency check of treatment decisions
        switch cell_statu.Value
            case tara.types.ReviewStatus.Unreviewed
                addFlag(cell_statu, "warning", description="This threat needs review")
            case {tara.types.ReviewStatus.Share, tara.types.ReviewStatus.Retain, tara.types.ReviewStatus.NotApplicable}
                % comment must be provided and claim must be linked
                sfaTemplate.AddFlagEmptyCell({cell_scmmt},{"Status requires a comment"},"error");
            case {tara.types.ReviewStatus.Avoid, tara.types.ReviewStatus.Reduce}
                sam.addFlagCellNotLinkedWithSheet({cell_lmeas}, {"countermeasures"}, {} ,"error");
        end

        %% check risk acceptance threshold
        if tara.types.SecurityRisk(cell_risk.Value) > tara.types.SecurityRisk.R_Medium && ...
            ~ismember(cell_statu.Value, [tara.types.ReviewStatus.NotApplicable, tara.types.ReviewStatus.Reduce, tara.types.ReviewStatus.Avoid, tara.types.ReviewStatus.Share])
            addFlag(cell_risk, "warning", Description="Risk is too high for the selected status.")
        end
    
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