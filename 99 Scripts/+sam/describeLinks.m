function [linksInfo, unresolved] = describeLinks(cellLinks, options)
% DESCRIBELINK Turns link(s) of a single cell into a human-readable txt.
% Returns a cell array of link descriptions, which is the same size as the
% input parameter (even if unresolved).
% Unresolved or stale links will have an empty linksInfo, additionally the 
% the return value "unresolved" is set to true if at least one link is so.
% Copyright 2024, The MathWorks, Inc

arguments
    cellLinks struct
    options.withArtifact logical = true
    options.rowNameFromColumn char = []  % for links to sheet: replace row num by a value in the given column
end

inLinks = cellLinks.inLinks;
outLinks = cellLinks.outLinks;
nlinks = numel(inLinks) + numel(outLinks);
[linksInfoIn, unresolved_in] = describeLinksOneDirection(inLinks, 'in', options);
[linksInfoOut, unresolved_out] = describeLinksOneDirection(outLinks, 'out', options);
linksInfo = [linksInfoIn, linksInfoOut];
unresolved = unresolved_in || unresolved_out;
assert(nlinks == numel(linksInfo));
end

function [linksInfo, unresolved] = describeLinksOneDirection(links, direction, options)
    unresolved = false;
    linksInfo = cell('', numel(links),1);
    for ll = 1:numel(links)
        if strcmp('in', direction)
            node = links(ll).source;
        else
            node = links(ll).destination;
        end
        describeDomainFunc = getHandler(node.domain);
        [linksInfo{ll}, lunres] = describeDomainFunc(node, options);
        unresolved = unresolved | lunres;
    end
end

function handler = getHandler(dom)
% two arguments: node, options
    switch(dom)
        case 'linktype_rmi_simulink'
            handler = @describeLinkToModel;
        case 'linktype_rmi_safetymanager'
            handler = @describeLinkToSheet;
        case 'linktype_rmi_slreq'
            handler = @describeLinkToReq;
        otherwise
            handler = @describeUnknown;
    end
end

function [linksInfo, unresolved] = describeUnknown(~,~)
    linksInfo = 'unknown';
    unresolved = true;
end

function [linkInfo, unresolved] = describeLinkToModel(node, options)
    comp = slreq.structToObj(node);
    if ~isempty(comp)
        if options.withArtifact
            [~, artf,ext] = fileparts(node.artifact);
            linkInfo = ['MDL: ' artf ext ':'];
        else
            linkInfo = [];
        end
        linkInfo = [linkInfo getfullname(comp.SimulinkHandle)];
        unresolved = false;
    else
        linkInfo = '??';
        unresolved = true;
    end
end

function [linkInfo, unresolved] = describeLinkToReq(node, options)
    % no need to make it an obj - enough info here
    if options.withArtifact
        linkInfo = ['REQ: ' node.reqSet ':'];
    else
        linkInfo = [];
    end
    % get summary
    reqt = slreq.structToObj(node);
    if ~isempty(reqt)
        linkInfo = [linkInfo node.id ': ' reqt.Summary];
        unresolved = false;
    else
        linkInfo = '??';
        unresolved = true;
    end
end

function [linkInfo, unresolved] = describeLinkToSheet(node, options)
    cell_or_row = slreq.structToObj(node);
    if ~isempty(cell_or_row)
        sheet = cell_or_row.getSpreadsheet();
        if options.withArtifact
            [~, fname] = fileparts(sheet.FileName);
            linkInfo = ['SHT: ' fname ':'];
        else
            linkInfo = [];
        end
        rownum = sam.getRowNum(cell_or_row);
        colnum = find(strcmp(sheet.getColumnLabels,options.rowNameFromColumn),1,'first');
        if ~isempty(options.rowNameFromColumn) && ~isempty(colnum)
            linkInfo = [linkInfo sheet.getCell(rownum,colnum).Value];
        else
            linkInfo = [linkInfo num2str(rownum)];
        end
        unresolved = false;
    else
        unresolved = true;
        linkInfo = '??';
    end
end