function [agg,dom] = computeAggregate(funHandle, tab, colname)
    % COMPUTEAGGREGATE Calc the aggregate value in a table, and return 
    % the element that dominates the aggregation. Used to find dominant risk.
    % Copyright 2024, The MathWorks, Inc.
    
    %arguments

    %end
    coldata = tab.(colname);
    if isa(coldata, "cell")
        coldata = [coldata{:}];
    end
    agg = funHandle(coldata);
    if nargout > 1
        try
            dom = tab.LinkText(coldata == agg);
        catch
            dom = []; % error, possibly implicit type cast
        end
    end
end