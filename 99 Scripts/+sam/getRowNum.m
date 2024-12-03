function rn = getRowNum(spreadsheetObj)
    if isa(spreadsheetObj, 'safetyAnalysisMgr.SpreadsheetCell')
        rn = spreadsheetObj.Row;
    elseif isa(spreadsheetObj, 'safetyAnalysisMgr.SpreadsheetRow')
        rn = spreadsheetObj.Index;
    else
        rn = -1;
    end
end