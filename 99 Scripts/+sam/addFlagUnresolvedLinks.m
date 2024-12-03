function is_stale = addFlagUnresolvedLinks(varargin)
%ADDFLAGUNRESOLVEDLINKS flags an error on a cell if it has broken links
%  is_stale = addFlagUnresolvedLinks(sheet, row, col)
%  is_stale = addFlagUnresolvedLinks(cell, links)
%  is_stale = addFlagUnresolvedLinks(cell)
% Copyright 2023-2024, The MathWorks, Inc.
    if 3 == nargin
        cell = getCell(varargin{1},varargin{2},varargin{3});
        links = cell.getLinks;  % XXX! costly
    elseif 2 == nargin
        cell = varargin{1};
        links = varargin{2};
    elseif 1 == nargin
        cell = varargin{1};
        links = cell.getLinks;
    end

    is_stale = false;
    if ~isempty(links.inLinks)
        % Workaround: x.isResolved can be true despite missing row in Sheet!
        is_stale = is_stale | any(arrayfun(@(x) isempty(slreq.structToObj(x.source)), links.inLinks));
    end
    if ~isempty(links.outLinks) && ~is_stale
        % Workaround: x.isResolved can be true despite missing row in Sheet!
        is_stale = any(arrayfun(@(x) isempty(slreq.structToObj(x.destination)), links.outLinks));
    end
    if is_stale
        addFlag(cell, "error", Description="Unresolved link(s)") 
    end
end

