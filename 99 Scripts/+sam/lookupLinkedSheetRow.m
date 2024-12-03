function [T, unresolved] = lookupLinkedSheetRow(links)
    % Returns a table that contains one row for each link to sheet. 
    % The table rows are the full rows of the linked sheets, plus columns 
    % for sheet, cell and a link text.
    % FIXME/R24b: use link-to-row feature instead of this clunky thing.
    % FIXME: use describeLinks() to get consistent output
    % Note: this fails if the links point to different Spreadsheets
    % Also returns a boolean "unresolved", indicating if links were broken
    % Copyright 2023-2024, The MathWorks, Inc.

    % collect links
    [sh1, c1] = sam.getLinkedSheetAndCell(links.inLinks, 'source');
    [sh2, c2] = sam.getLinkedSheetAndCell(links.outLinks, 'dest');
    sheets = [sh1, sh2]; % cell arr
    objs = [c1, c2];    % cell arr of SpreadsheetCell or SpreadsheetRow
    sheetFiles = cellfun(@(x) x.FileName, sheets, 'UniformOutput', false);
    assert(isempty(sheets) || isscalar(unique(sheetFiles)), "All links must point to the same sheet");
    % build the table
    linkdata = cell(numel(sheets), 3);
    linkdata(:,1) = sheets';
    linkdata(:,2) = objs';
    linkdata(:,3) = makeLinkText(sheets, objs);  % NOT using describeLinks, because here we only look at linked Sheets, which is a subset of all possible links
    T = cell2table(linkdata, "VariableNames", ["Sheet", "LinkedObj", "LinkText"]);
    % add data of linked rows. All rows are in the same sheet.
    if height(T) > 0    
        Tdata = table();
        cols = T.Sheet(1).getColumnLabels;
        % PERF: 43x -> 0.143s. Maybe not ideal, since we jump between rows
        for i = 1:numel(cols)
            Tdata.(cols(i)) = cellfun(@(sh, obj) getCell(sh, sam.getRowNum(obj), i).Value, ...
                                  sheets', objs', 'UniformOutput', false);
        end
        T = [T, Tdata];
    end
    unresolved = height(T) < (numel(links.inLinks) + numel(links.outLinks));
end

function txt = makeLinkText(sheets, obj)
txt = cell(size(sheets));
for k=1:numel(sheets)
    [~,f] = fileparts(sheets{k}.FileName);
    rownum = sam.getRowNum(obj{k});
    if rownum > 0
        rownum = string(rownum);
    else
        rownum = "?";
    end
    txt{k} = string(f) + ":" + rownum;
end
end
