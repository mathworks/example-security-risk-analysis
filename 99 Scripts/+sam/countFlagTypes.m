function [counts, highest] = countFlagTypes(sheet, baseline)
% count number of flags by category. If baseline is given, computes the
% delta between current and baseline.
% Returns: "highest" is the most critical flag category != 0.
% Copyright 2023-2024, The MathWorks, Inc.
arguments
    sheet safetyAnalysisMgr.Spreadsheet
    baseline = []
end
    types = {'warning','error','check'};
    counts = count(getFlags(sheet), types);
    if ~isempty(baseline)
        counts_baseline = count(baseline, types);
        counts = counts - counts_baseline;
    end
    counts = cell2struct(num2cell(counts), types, 2);
    % calc highest
    if counts.error > 0
        highest = 'error';
    elseif counts.warning > 0
        highest = 'warning';
    elseif counts.check > 0
        highest = 'check';
    else
        highest = '';
    end

    function numbers = count(flags, types)
        flagtype = arrayfun(@(x) x.Type, flags, 'UniformOutput',false);
        numbers = cellfun(@(x) nnz(strcmp(flagtype, x)), types);
    end
end