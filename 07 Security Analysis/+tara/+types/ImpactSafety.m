classdef ImpactSafety < uint16
    enumeration 
        S_Negligible(1), % no injuries
        S_Moderate(2), % light/moderate injuries
        S_Major(3), % severe injuries, survival probably
        S_Severe(4), % fatal, survival uncertain
    end
end

