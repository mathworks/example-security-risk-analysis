classdef AttackElapsedTime < uint16
    % See ISO/SAE 21434:2021 G.2.2.1.
    % The elapsed time parameter includes the time to identify a 
    % vulnerability and develop and (successfully) apply an exploit.
    enumeration
        ET_1Day(0),
        ET_1Week(1),
        ET_1Month(4),
        ET_6Month(17)
        ET_Longest(19)
    end
end

