classdef ImpactTotal < uint16
    % For ISO/SAE 21434:2021 Annex E.1 (CAL determination).
    enumeration 
        T_Negligible(1),
        T_Moderate(2),
        T_Major(3),
        T_Severe(4)
    end
end

