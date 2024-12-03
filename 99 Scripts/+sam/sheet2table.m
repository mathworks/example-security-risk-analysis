function T = sheet2table(sheet,columns,options)
% SHEET2TABLE exports one sheet of SafetyAnalysisManager to a ML table.
% Copyright 2023-2024, The MathWorks, Inc

    arguments
        sheet safetyAnalysisMgr.Spreadsheet
        columns string = sheet.getColumnLabels();  % choose which columns to export
        options.ExportLinks logical = false % whether to add link information as a column
        options.ExportDescription logical = false  % whether to export cell descriptions, too
        options.Stringify logical = false  % whether cells are casted to strings
        options.ExportFlags logical = true % whether to add flag information as a column
        options.ExportChanges logical = false % whether to add change information as column
        options.makeIDs logical = true; % whether to add column "ID"
    end
    assert(~(options.ExportLinks & ~options.Stringify)); % not supported, because not so easy to see if column is empty

    %% collect data and links from sheet    
    columns = columns(~startsWith(columns, "_"));  % remove private columns
    % for performance: column names to indices, to avoid costly lookup
    lbls = sheet.getColumnLabels;
    cids = arrayfun(@(x) find(lbls == x,1,'first'), columns);

    samColLabels = columns;
    samValues = cell(sheet.Rows,numel(cids));
    samLinks = cell(sheet.Rows,numel(cids)+1);  % one more for row links
    for rowid = 1:sheet.Rows
        for colid = 1:numel(cids)
            onecell = sheet.getCell(rowid,cids(colid));
            cellContent = onecell.Value;
            if options.Stringify
                cellContent = string(cellContent);
                if options.ExportDescription & ~isempty(onecell.Description)
                    cellContent = cellContent + ": " + string(newline) + string(onecell.Description);
                end
            end
            samValues{rowid,colid} = cellContent;
            if options.ExportLinks
                samLinks{rowid,colid} = onecell.getLinks();
            end
        end
        % Check if there are row links
        if options.ExportLinks && ismethod(sheet, 'getRow')
            samLinks{rowid,colid+1} = sheet.getRow(rowid).getLinks();
        end
    end
    % turn links into readable strings
    if options.Stringify && options.ExportLinks
        samLinks = cellfun(@(x) makeLinkText(x), samLinks, 'UniformOutput', false);
    end
    % types to table - FIXME: only works if table has data, since we cannot 
    % query the column type yet
    if 0 < sheet.Rows
        samUnits = arrayfun(@(c) class(sheet.getCell(1,c).Value), cids, 'UniformOutput', false);
    else
        samUnits = strings(1,numel(cids));
    end

    %% make a real table
    % Initialize the output cell array to have same number of rows as the
    % original Safety Analysis Manager spreadsheet but twice number of
    % columns, because every column can have a) values and b) links
    outputNumRows = size(samValues,1);
    outputNumCols = size(samValues,2)*2;
    tabData = cell(outputNumRows,outputNumCols);
    tabHead = cell(1,outputNumCols);
    linkColSuffix = '.Links';
    for colid = 1:outputNumCols
        if rem(colid,2) == 1
            % Assign values to the odd columns
            inputCol = (colid+1)/2;
            tabData(:,colid) = samValues(:,inputCol);
            tabHead{colid} = samColLabels{inputCol};
        else
            % Assign links to the even columns
            inputCol = colid/2;
            tabData(:,colid) = samLinks(:,inputCol);
            tabHead{colid} = append(samColLabels{inputCol},linkColSuffix);
        end
    end
    % row links
    tabHead{end+1} = 'ReferencedBy'; % FIXME: is this a good name?
    tabData(:,end+1) = samLinks(:,end);
    % --
    T = cell2table(tabData, 'VariableNames', tabHead);
    samUnits = [samUnits; repmat("links", size(samUnits))];
    samUnits = samUnits(:);  % bring into right order...little trick :)
    samUnits = [samUnits; "links"];  % one more for the row link
    T.Properties.VariableUnits = samUnits(:);

    % drop link-columns which have no content
    linkColNames = T.Properties.VariableNames(endsWith(T.Properties.VariableNames, linkColSuffix));
    emptyLinkColumns = cellfun(@(x)isColumnEmpty(T, x), linkColNames);
    T = removevars(T, linkColNames(emptyLinkColumns));

    %% postprocessing
    if options.ExportFlags
        % add column that summarizes the flags per row
        T.Flags(:) = "OK"; % default
        allflags = sheet.getFlags;
        if ~isempty(allflags)
            wrnFlags = allflags(strcmpi({allflags.Type}, 'warning'));
            rowsWithWrn = unique(cellfun(@(x) sam.getRowNum(x), {wrnFlags.FlaggedObject}));
            T.Flags(rowsWithWrn) = "WARN";
            errFlags = allflags(strcmpi({allflags.Type}, 'error'));
            rowsWithErr = unique(cellfun(@(x) sam.getRowNum(x), {errFlags.FlaggedObject}));
            T.Flags(rowsWithErr) = "ERROR";
        end
    end
    if options.ExportChanges
        sheet.detectChanges();
        % add column that summarizes if this row has unseen changes
        T.Changes(:) = "";
        allchanges = sheet.getChanges;
        if ~isempty(allchanges)
            % TODO: check..if this line works
            rowsWithChg = unique(cellfun(@(ch) sam.getRowNum(x), {ch.AffectedElement}));
            T.Changes(rowsWithChg) = "UNREVIEWED CHANGES";
        end
    end
    if options.makeIDs
        ID = [1:height(T)]'; %#ok<NBRAK1>
        T = addvars(T, ID, 'before', 1);
    end
end

% Utility functions
function blank = isColumnEmpty(tab, colname)
    blank = all(cellfun(@(x) isempty(x), tab.(colname))); % for strings
    %blank = isempty(tab.(colname));
end

function txt = makeLinkText(links)
    % make sure that missing links are absolutely visible in the export
    [desc, unresolved] = sam.describeLinks(links);
    if unresolved
        desc = ["!!!unresolved!!!", desc];
    end
    txt = join(string(desc), "; ");
end