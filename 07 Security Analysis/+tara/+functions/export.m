function filename = export(filename)
%EXPORT Generate a report from SAM sheets in simplified Excel format.
% Copyright 2024, The MathWorks, Inc.
filename = convertStringsToChars(filename);

[~,~,ext] = fileparts(filename);
switch lower(ext)
    case {'.xls','.xlsx'}
    otherwise
        error('Unrecognized report format.')
end

%% generate
if isfile(filename)
    delete(filename);
end
openSheets = safetyAnalysisMgr.getOpenDocuments;
for samSheet = openSheets
    [~,sheetname,~] = fileparts(samSheet.FileName);
    disp('---------------------------------')
    disp(['Processing sheet *' sheetname '* ...'])
    sam.validateSheet(samSheet);
    disp(['Writing sheet ' sheetname]);
    sam.sheet2Excel(filename, sheetname, samSheet);
end

disp(['Successfully exported TARA to ' filename]);
try
    winopen(filename);
catch
    open(filename);
end
end