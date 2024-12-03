function nbad = validateAssets(sheet)
% This function validates the SFA sheet "assets".
%
% Copyright 2023-2024, The MathWorks, Inc.
nok = validateSheet(sheet);
nbad = sheet.Rows - nok;
disp(['Validated assets: ' ...
      num2str(nbad) ' assets incomplete, ' num2str(sheet.Rows) ' in total'])
end

function n_ok = validateSheet(sheet)
    % runs completeness checks on the threats and creates flags
    n_ok = 0;
    
    thisSheet = sam.SheetWrapper(sheet);
    for rowIndex = 1:sheet.Rows
        oldflags = getFlags(sheet);
        cell_ok = thisSheet.Cell(rowIndex,"OK?");
        cell_apath = thisSheet.Cell(rowIndex,"ModelElement");
        cell_thrts = thisSheet.Cell(rowIndex,"LinkedThreats");
        cell_atype = thisSheet.Cell(rowIndex,"AssetType");
        cell_authn = thisSheet.Cell(rowIndex,"Authenticity");
        cell_integ = thisSheet.Cell(rowIndex,"Integrity");
        cell_avail = thisSheet.Cell(rowIndex,"Availability");
        
        %% flag missing or wrong links
        % link to model: if non-empty cell, then it must have a link
        if ~isempty(cell_apath.Value)
            msg = {("'" + cell_apath.ColumnLabel + "' column should link to the correspondent model element")};
            sam.addFlagCellNotLinkedWithModel({cell_apath}, msg ,"error")
        end
        sam.addFlagWrongLinkDirection(true, cell_apath);
        % link to threat(s) are obligatory
        sam.addFlagCellNotLinkedWithSheet({cell_thrts}, {"threats"}, {} ,"error");

        %% Flag missing cybersec properties (according to simplified STRIDE)
        switch cell_atype.Value
            case tara.types.AssetType.Actor
                % - For actors: Spoofing, Repudiation -> Authc, NR
                addFlagIfPropertyNotSelected(cell_authn);
            case {tara.types.AssetType.Flow, tara.types.AssetType.Store}
                % tampering, ID, DoS -> integrity,availability
                addFlagIfPropertyNotSelected(cell_integ);
                addFlagIfPropertyNotSelected(cell_avail);
            case tara.types.AssetType.Process
                % - For process: ALL
                addFlagIfPropertyNotSelected(cell_authn);
                addFlagIfPropertyNotSelected(cell_integ);
                addFlagIfPropertyNotSelected(cell_avail);
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

function flagged = addFlagIfPropertyNotSelected(cell)
% if a cell has a deseleced checkbox AND no description to justify why,
% then add a flag
    if isempty(cell.Description) && ~cell.Value
        addFlag(cell, "warning", Description="Should apply for this asset type, unless you added a description")
        flagged = true;
    else
        flagged = false;
    end
end