function txt = itemizeText(list)
% Turn a list of strings to bulletpoints
% Copyright 2023-2024, The MathWorks, Inc.
    txt = join([repmat("- ", size(list)); list], 1); % itemize
    txt = strjoin(txt, ',\n');
end

