classdef AttackVector < uint16
    % See ISO/SAE 21434:2021 G.9. See also CVSS.
    enumeration
        Physical(1), % physical access to the item
        Local(2), % no network, direct access to the item
        Adjacent(3), % local network access required
        Network(4) % remote network access is sufficient
    end
end

