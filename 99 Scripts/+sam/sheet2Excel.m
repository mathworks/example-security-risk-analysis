function sheet2Excel(xlsfile, xlssheet, samSheet)
% SHEET2EXCEL exports one sheet of Safety Analysis Manager to MS Excel.
%    Links are exported, and described so that they are tracable.
% Copyright 2023-2024, The MathWorks, Inc

% Exctract the data from the table
tabSpreadsheetComplete = sam.sheet2table(samSheet, Stringify=true, ExportLinks=true, ExportDescription=true);

%% send to Excel sheet
writetable(tabSpreadsheetComplete, fullfile(pwd, xlsfile), ...
           'Sheet', xlssheet, 'WriteMode','overwritesheet', ...
           'AutoFitWidth',true);
end
