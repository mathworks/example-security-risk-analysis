% Helper function to add the flag for cell with no link to model element.
% Insensitive to link direction.
%
% Copyright 1984-2023 The MathWorks, Inc
%
function addFlagCellNotLinkedWithModel(cell_list_handle,cell_list_message,flagtype)
    for i = 1:numel(cell_list_handle)
        % Get the links for every cell
        links = cell_list_handle{i}.getLinks;
        sam.addFlagUnresolvedLinks(cell_list_handle{i}, links);
        % For inlinks and outlinks check if at least one link is to a model
        % elment. If not set the warning
        checkInLink = getLinkedDomain(links.inLinks);
        checkOutLink = getLinkedDomain(links.outLinks);
        if ~(checkInLink || checkOutLink)
            if ~isempty(cell_list_message) 
                msg = cell_list_message{i};
            else
                msg = "Cell should link to model";
            end
            addFlag(cell_list_handle{i},flagtype,Description=msg);
        end
    end
end

%% Utility Function
% Helper function to check whether the domain extension is a model
function check = getLinkedDomain(links)
    check = 0;
    for link = links
        [~,~,exts] = fileparts(link.source.artifact);
        [~,~,extt] = fileparts(link.destination.artifact);
        if any(strcmpi({exts,extt},'.slx'))
            check = 1;
            break
        end
    end
end


