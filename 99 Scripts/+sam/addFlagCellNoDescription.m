function is_stale = addFlagCellNoDescription(cell_list_handle,cell_list_message,flagtype)
%ADDFLAGCELLNODESCRIPTION flags an error on a cell if it has an empty
%description.
% Copyright 2023-2024, The MathWorks, Inc.
    for i = 1:numel(cell_list_handle)
        if isempty(cell_list_handle{i}.Description)
            if ~isempty(cell_list_message) 
                msg = cell_list_message{i};
            else
                msg = "Cell description should not be empty";
            end
            addFlag(cell_list_handle{i},flagtype,Description=msg);
        end
    end
end

