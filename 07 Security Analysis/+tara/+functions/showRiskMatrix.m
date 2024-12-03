% Copyright 2023-2024, The MathWorks, Inc.
% choose your types here:
y = "tara.types.AttackFeasibility"; % same feasibility for all risks
x = "tara.types.ImpactSafety";
rf = "tara.functions.computeRisk"; % the risk function
f = figure('Name','Risk Matrix');
subplot(1,1,1); plotOneMatrix("Safety Risk", x, y, rf);

function plotOneMatrix(tit, xEnumName, yEnumName, riskFunction)
    % calc outer product
    valX = enumeration(xEnumName);
    valY = flip(enumeration(yEnumName));
    [xx, yy] = meshgrid(valX, valY);
    matrix = arrayfun(@(ix, iy) feval(riskFunction, ix, iy), ...
                        feval(xEnumName, xx), feval(yEnumName, yy));
    % plot nicely
    h = heatmap(double(matrix), 'ColorbarVisible', 'off');
    title(tit);
    colormap('turbo');
    xlabel(xEnumName);
    ylabel(yEnumName);
    h.XData = string(valX);
    h.YData = string(valY);
    h.Interpreter = 'none';
end