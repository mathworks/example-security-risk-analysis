classdef SheetWrapper < handle
    %Provides convenient & fast access to Safety Analysis Manager Sheets,
    % and reports (only once) when columns are missing
    % Copyright 2023-2024, The MathWorks, Inc.
    
    properties (Access=private)
        sheet
        columns
        missingColumns
    end
    
    methods
        function obj = SheetWrapper(sheet)
            arguments
                sheet safetyAnalysisMgr.Spreadsheet
            end
            obj.sheet = sheet;
            obj.columns = dictionary(sheet.getColumnLabels(), 1:sheet.Columns); % perf
            obj.missingColumns = string.empty;
        end

        function outCell = Cell(obj,row,colName)
            %CELL returns a cell based on row number and column name, or
            %empty if not existing
            colNum = lookup(obj.columns,colName,FallbackValue=0);
            if 0 ~= colNum
                outCell = getCell(obj.sheet,row,colNum);
            else
                obj.reportMissing(colName);
                outCell = [];
            end
        end
    end

    methods (Access=private)
        function reportMissing(obj, colName)
            if ~ismember(colName, obj.missingColumns)
                obj.missingColumns(end+1) = colName;
                warning("Sheet " + string(obj.sheet.FileName) + " misses column """ + string(colName) + """");
            end
        end
    end
end

