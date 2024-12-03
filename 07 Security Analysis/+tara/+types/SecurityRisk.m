classdef SecurityRisk < uint16
    enumeration
        R_Negligible(1),
        R_Low(2),
        R_Medium(3),
        R_High(4),
        R_Critical(5),
        
        % R_Extreme(7) % robustness test case for computeRisk()
    end
end

