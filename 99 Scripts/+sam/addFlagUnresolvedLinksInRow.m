% ADDFLAGUNRESOLVEDLINKS Flag all cells with unresolved links in a row
% Note: this function is costly. If possible, use addFlagUnresolvedLinks
%       only on those cells which are known to have links.
% Copyright 2023-2024, The MathWorks, Inc.

function hasFlag = addFlagUnresolvedLinksInRow(samSheet, row)
hasFlag = false;
for col = 1:samSheet.Columns
    hasFlag = hasFlag | sam.addFlagUnresolvedLinks(samSheet, row, col);
end
end

