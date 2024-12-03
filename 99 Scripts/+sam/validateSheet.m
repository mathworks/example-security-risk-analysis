function validateSheet(sfa_spreadsheet)
    %VALIDATESHEET Run analysis callback "validate" on a SAM sheet
    % Copyright 2024, The MathWorks, Inc.
    sfa_spreadsheet.clearFlags();
    try %#ok<TRYNC>
        cb_code = sfa_spreadsheet.getCallback('validate');
        eval(cb_code);
    end
    try %#ok<TRYNC>
        cb_code = sfa_spreadsheet.getCallback('Validate');
        eval(cb_code);
    end
end