function [txt, counts] = summarizeSheet(sheet, options)
% Given a single sheet, extracts description, and summarizes flags in dict
% Copyright 2024, The MathWorks, Inc.
arguments
    sheet safetyAnalysisMgr.Spreadsheet
    options.allFlagsInRow = false  % if true, do not only show the dominant flag per row, but ALL
    options.flagsBaseline = [] % if non-empty, calculates delta to previous flags
end
    txt = string(sheet.Description);
    ff = sheet.getFlags();
    if ~isempty(ff)
        if ~options.allFlagsInRow
            % we reduce each row to one flag
            rows = arrayfun(@(x) sam.getRowNum(x.FlaggedObject), ff);
            groupedByRow = arrayfun(@(rownum) {ff(rows == rownum).Type}, 1:sheet.Rows, 'UniformOutput',false); % cellarr of arr
            types = cellfun(@highest, groupedByRow, 'UniformOutput',false);
        else
            % we don't care how many flags in each row
            types = {ff.Type};
        end
    else
        types = {};
    end
    %% count each type of flag
    counts = countStrings(types);
    if ~isempty(options.flagsBaseline)
        error("Not implemented")  % TODO
    end
end

function counts = countStrings(someStrings)
    % returns dict: string -> count
    counts = configureDictionary("string", "double");
    if ~isempty(someStrings)
        [typ,~,idt]=unique(someStrings);
        cnt = accumarray(idt, ones(size(idt)));
        counts = dictionary(string(typ), cnt');
    end
end

function hi = highest(cellofstrings)
    if ismember("error", cellofstrings)
        hi = 'error';
    elseif ismember("warning", cellofstrings)
        hi = 'warning';
    elseif ismember("check", cellofstrings)
        hi = 'check';
    else
        hi = '';
    end
end