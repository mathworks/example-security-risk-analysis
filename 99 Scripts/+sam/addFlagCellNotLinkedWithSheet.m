% Helper function to add the flag for cell (or row) with no link to model element
% Insensitive to link direction.
%
% Copyright 1984-2023 The MathWorks, Inc
%
function addFlagCellNotLinkedWithSheet(list_rowsorcells,list_sheet,list_message,flagtype)
    arguments
        list_rowsorcells cell
        list_sheet cell
        list_message
        flagtype char
    end

    for i = 1:numel(list_rowsorcells)
        links = list_rowsorcells{i}.getLinks; % XXX costly!
        sheet = list_sheet{i};
        sam.addFlagUnresolvedLinks(list_rowsorcells{i}, links);
        if ~(linksWithSheet(sheet, links.inLinks, 'source') || ...
             linksWithSheet(sheet, links.outLinks, 'dest'))
            if ~isempty(list_message) 
                msg = list_message{i};
            else
                msg = "Should link to sheet '" + convertCharsToStrings(sheet) + "'";
            end
            addFlag(list_rowsorcells{i},flagtype,Description=msg);
        end
    end
end

function foundit = linksWithSheet(sheetname, links, direction)
    sheets = repmat("", size(links));
    for li = 1:numel(links)
        link = links(li);
        if strcmpi(direction, 'source')
            [~,sname,exts] = fileparts(link.source.artifact);
        else
            [~,sname,exts] = fileparts(link.destination.artifact);
        end
        if strcmpi(exts,'.mldatx')
            sheets{li} = sname;
        end
    end
    sheets = unique(sheets);
    foundit = any(sheets == sheetname);
end

