function nup = updateThreats(sheet)
% This function collects information into the "threat" sheet (SFA) from
% the linked damage scenarios and attack paths.
%
% Copyright 2023-2024, The MathWorks, Inc.
    nup = updateSheet(sheet);
    detectChanges(sheet);
    disp(['Completed update: ' num2str(nup) ' threats updated'])
end

function n_upd = updateSheet(sheet)
    % update all columns related to risk, based on the linked sheets
    n_upd = 0;
    thisSheet = sam.SheetWrapper(sheet);
    for rowIndex = 1:sheet.Rows
        cell_lflt  = thisSheet.Cell(rowIndex,"LinkedFaults");
        cell_lcms  = thisSheet.Cell(rowIndex,"LinkedCountermeasures");
        % the following are written by this function and should not be
        % exposed to the user:
        cell_impts = thisSheet.Cell(rowIndex,"_MaxImpact");

        %% compute aggregate impacts from all associated faults
        [T, ~] = sam.lookupLinkedSheetRow(cell_lflt.getLinks);
        % -- write outputs
        if height(T) > 0
            [aggImpt, domImpt] = sam.computeAggregate(@max, T, "Severity");
            cell_impts.Value = tara.types.ImpactSafety(aggImpt);
            % readable links and writ output of dominance analysis:
            [linkText, ~] = sam.describeLinks(cell_lflt.getLinks, withArtifact=false, rowNameFromColumn='Functional Failure');
            cell_lflt.Value = sam.itemizeText(linkText);
            cell_lflt.Description = "dominant: " + strjoin(unique(domImpt), ", ");
        else
            cell_lflt.Value = "";
            cell_lflt.Description = "";
        end   

        %% write summary of linked countermeasures into sheet
        [linkText, ~] = sam.describeLinks(cell_lcms.getLinks, withArtifact=false, rowNameFromColumn='Summary');
        cell_lcms.Value = sam.itemizeText(linkText);
    end
end