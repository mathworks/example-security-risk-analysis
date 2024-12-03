classdef AttackEquipment < uint16
    % See ISO/SAE 21434:2021 G.2.2.5.
    enumeration
        EQ_Standard(0), % Equipment is readily available to the attacker. This equipment can be a part of the product itself (e.g. a debugger in an operating system), or can be readily obtained (e.g. internet sources, protocol analyser or simple attack scripts).
        EQ_Specialized(4), % Equipment is not readily available to the attacker but can be acquired without undue effort. This can include purchase of moderate amounts of equipment (e.g. power analysis tools, use of hundreds of PCs linked across the internet would fall into this category), or development of more extensive attack scripts or programs. If clearly different test benches consisting of specialized equipment are required for distinct steps of an attack this would be rated as bespoke.
        EQ_Bespoke(7), % Equipment is specially produced (e.g. very sophisticated software) and not readily available to the public (e.g. black market), or the equipment is so specialized that its distribution is controlled, possibly even restricted. Alternatively, the equipment is very expensive
        EQ_MultiBespoke(9) % Is introduced to allow for a situation, where different types of bespoke equipment are required for distinct steps of an attack.
    end
end

