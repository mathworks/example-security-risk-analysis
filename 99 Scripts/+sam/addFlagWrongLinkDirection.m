function is_wrong = addFlagWrongLinkDirection(flag_outgoing, varargin)
%ADDFLAGWRONGLINKDIRECTION flags an error on a cell if it has one or more 
% links of unwanted directionality.
%  is_wrong = addFlagWrongLinkDirection(ldir,sheet,row,col)
%  is_wrong = addFlagWrongLinkDirection(ldir,cell,links)
%  is_wrong = addFlagWrongLinkDirection(ldir,cell)
% Copyright 2023-2024, The MathWorks, Inc.
    if 4 == nargin
        cell = getCell(varargin{1},varargin{2},varargin{3});
        links = cell.getLinks;  % XXX! costly
    elseif 3 == nargin
        cell = varargin{1};
        links = varargin{2};
    elseif 2 == nargin
        cell = varargin{1};
        links = cell.getLinks;
    end

    is_wrong = false;
    if flag_outgoing && ~isempty(links.outLinks)
        is_wrong = true;
        wanted = "incoming";
    elseif ~flag_outgoing && ~isempty(links.inLinks)
        is_wrong = true;
        wanted = "outgoing";
    end
    if is_wrong
        addFlag(cell, "error", Description="Some links have wrong direction. Should be " + wanted) 
    end
end

