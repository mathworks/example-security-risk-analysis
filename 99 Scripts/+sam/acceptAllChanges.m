function acceptAllChanges()
    %ACCEPTALLCHANGES Create baseline for change detection on all opened
    %sheets.
    % Copyright 2024, The MathWorks, Inc.
    openSheets = safetyAnalysisMgr.getOpenDocuments;
    for samSheet = openSheets
        [~,sheetname,~] = fileparts(samSheet.FileName);
        disp(['Creating baseline for sheet *' sheetname '* ...'])
        samSheet.acceptAllChanges;
    end
    disp('Baselining done');
end