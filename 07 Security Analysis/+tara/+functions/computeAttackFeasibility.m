function feasibility = computeAttackFeasibility(parm)
%COMPUTEATTACKFEASIBILITY 
%   feasibility = computeAttackFeasibility(AttackVector)
%       This calculages the feasibility based on the attack vector,
%       as described in ISO/SAE 21434:2021 G.4. This approach is useful for 
%       early TARA.
%
%   feasibility = computeAttackFeasibility(AttackPotential)
%       This calculates the feasbilility using the attack potential, as 
%       described in ISO/SAE 21434:2021 G.2. This approach is useful for 
%       later designs stages
% Copyright 2023-2024, The MathWorks, Inc.
if isa(parm, 'tara.types.AttackVector')
    feasibility = vector2feasibility(parm);
elseif isa(parm, 'tara.types.AttackPotential')
    feasibility = potential2feasibility(parm);
else
    error("unsupported argument type");
end
end

function feasibility = vector2feasibility(av)
    % linear mapping between Attack Vector (av) and Attack Feasibility (af)
    vv = double(enumeration(av));
    vf = double(enumeration("tara.types.AttackFeasibility"));
    val = round(interp1([min(vv),max(vv)], [min(vf),max(vf)], double(av)));
    feasibility = tara.types.AttackFeasibility(val);
end

function feasibility = potential2feasibility(ap)
    % as suggested in ISO/SAE 21434:2021 G 2.2.6.
    val = ap.getValue();
    if val >= 25
        feasibility = tara.types.AttackFeasibility.VeryLow;
    elseif val >= 20
        feasibility = tara.types.AttackFeasibility.Low;
    elseif val >= 14 
        feasibility = tara.types.AttackFeasibility.Medium;
    else
        feasibility = tara.types.AttackFeasibility.High;
    end
end

