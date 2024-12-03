function [inLinks,outLinks,inLinksObj,outLinksObj] = getAllLinksInRow(sheet,rowid)
%GETALLLINKSINROW For SAM. Fetches all links in a row.
% Copyright 2023-2024, The MathWorks, Inc.
linkedObj = arrayfun(@(x) sheet.getCell(rowid, x), 1:sheet.Columns, 'UniformOutput',false);
rowlinks = cellfun(@(cc) cc.getLinks, linkedObj);
% split I/O
linkOut = arrayfun(@(x) x.outLinks, rowlinks, 'UniformOutput', false);
linkIn = arrayfun(@(x) x.inLinks, rowlinks, 'UniformOutput', false);
% also get row links
if ismethod(sheet, 'getRow')  % R24b+
    rowobj = sheet.getRow(rowid);
    linkedObj{end+1} = rowobj;
    rowLinks = rowobj.getLinks;
    linkIn{end+1} = rowLinks.inLinks;
    linkOut{end+1} = rowLinks.outLinks;
end
% back to a struct array
inLinks = horzcat(linkIn{:});
outLinks = horzcat(linkOut{:});
if nargout > 2
    inLinksObj = linkedObj(~cellfun(@isempty, linkIn));
end
if nargout > 3
    outLinksObj = linkedObj(~cellfun(@isempty, linkOut));
end
end