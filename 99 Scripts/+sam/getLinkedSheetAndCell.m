function [DestSheet,DestObj] = getLinkedSheetAndCell(linkArray, linkType)
%Given a link from a cell in Spreadsheet A to a cell in Spreadsheet B, 
% this returns B and the specific Cell or Row in B.
% With a better API this should not be necessary.
% Copyright 2023-2024, The MathWorks, Inc.
DestSheet = {};
DestObj  = {};
for link = linkArray
    if link.isResolved %% XXX costly and not reliable!
        if strcmpi('source', linkType)
            link_node = link.source;
        else
            link_node = link.destination;
        end
        if strcmp(link_node.domain, 'linktype_rmi_safetymanager')
            linkedObj = slreq.structToObj(link_node); % !! this can return empty even for resolved links
            if ~isempty(linkedObj)
                DestObj{end+1} = linkedObj;
                DestSheet{end+1} = linkedObj.getSpreadsheet;
            end
        end
    end
end
assert(numel(DestSheet) == numel(DestObj))
end

