function [sheets,rows] = getSelectedSheetsAndRows()
%GETSELECTEDSHEETSANDROWS In Safety Manager App
% Copyright 2023-2024, The MathWorks, Inc.
sheets = [];
rows = [];

selStuff = safetyAnalysisMgr.getCurrentSelection;
if ~isempty(selStuff)
    % this is tricky. It may return an array of cells, or an array of rows
    sheets = arrayfun(@(x) x.getSpreadsheet, selStuff, 'UniformOutput', false);
    rows = arrayfun(@(x) sam.getRowNum(x), selStuff);
    sheetName = cellfun(@(x) x.FileName, sheets, 'UniformOutput', false);
    % remove duplicates
    T = table(sheetName', rows');
    [~,idx] = unique(T);
    sheets = sheets(idx);
    rows = rows(idx);
end
end

