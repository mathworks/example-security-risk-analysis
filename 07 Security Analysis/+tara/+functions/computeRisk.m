function riskEnum = computeRisk(impact, feasibility)    
% The "risk matrix".
% Copyright 2023-2024, The MathWorks, Inc.

impact = tara.types.ImpactSafety(impact);
feasibility = tara.types.AttackFeasibility(feasibility);

rangeRisk = tara.functions.getEnumRange("tara.types.SecurityRisk");
rangeImpt = tara.functions.getEnumRange(impact);
rangeFeas = tara.functions.getEnumRange(feasibility);
% -- linear mapping
rangeProduct = rangeImpt .* rangeFeas;
valueProduct = double(impact) * double(feasibility);
riskVal = round(interp1(rangeProduct, rangeRisk, valueProduct));

% FIXME: might fail if the SecurityRisk enum has (numeric) gaps. Need to
% calculate the closest value
riskEnum = tara.types.SecurityRisk(riskVal);
end