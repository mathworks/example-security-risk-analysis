classdef AttackWindow < uint16
    % See ISO/SAE 21434:2021 G.2.2.4.
    enumeration
        WO_Unlimited(0), % High availability via public/untrusted network without any time limitation (i.e. asset is always accessible). Remote access without physical presence or time limitation as well as unlimited physical access to the item or component.
        WO_Easy(1), % High availability and limited access time. Remote access without physical presence to the item or component.
        WO_Moderate(4), % Low availability of the item or component. Limited physical and/or logical access. Physical access to the vehicle interior or exterior without using any special tools.
        WO_Difficult(10) % Very low availability of the item or component. Impractical level of access to the item or component to perform the attack.
    end
end

