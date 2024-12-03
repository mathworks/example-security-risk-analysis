function value = computeExecMeans(attackExpertise, attackEquipment)
%COMPUTEPREPMEANS Copied from DO-356 Table D-3
% Execution effort = expertise * equipment
% Copyright 2023-2024, The MathWorks, Inc.

if isa(attackExpertise, 'char')
    attackExpertise = tara.types.AttackExpertise(attackExpertise);
end
if isa(attackEquipment, 'char')
    attackEquipment = tara.types.AttackEquipment(attackEquipment);
end

% verbatim from Table
pmMatrix = [0 1 3 5; % lowest impact
            1 3 4 7;
            3 5 7 10;
            6 8 10 12]; % highest impact

% map enums to indices
[idxRow,nRow] = enumIndex(attackExpertise);
[idxCol,nCol] = enumIndex(attackEquipment);
assert(isequal([nCol,nRow],size(pmMatrix)));
value = pmMatrix(idxRow, idxCol);
end

function [idx,num] = enumIndex(enumValue)
    [~,enum_tags] = enumeration(enumValue);
    num = numel(enum_tags);
    idx = find(strcmp(enumValue, enum_tags));
end

