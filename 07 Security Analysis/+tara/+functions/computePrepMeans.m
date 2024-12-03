function value = computePrepMeans(attackKnowledge, attackEquipment)
%COMPUTEPREPMEANS Copied from DO-356 Table D-1. 
% Preparation effort = knowledge * equipment
% Copyright 2023-2024, The MathWorks, Inc.

if isa(attackKnowledge, 'char')
    attackKnowledge = tara.types.AttackKnowledge(attackKnowledge);
end
if isa(attackEquipment, 'char')
    attackEquipment = tara.types.AttackEquipment(attackEquipment);
end

% verbatim from Table
pmMatrix = [0 1 2 3; % lowest impact
            1 1 3 4;
            2 3 4 5;
            3 4 5 6]; % highest impact

% map enums to indices
[idxRow,nRow] = enumIndex(attackKnowledge);
[idxCol,nCol] = enumIndex(attackEquipment);
assert(isequal([nCol,nRow],size(pmMatrix)));
value = pmMatrix(idxRow, idxCol);
end

function [idx,num] = enumIndex(enumValue)
    [~,enum_tags] = enumeration(enumValue);
    num = numel(enum_tags);
    idx = find(strcmp(enumValue, enum_tags));
end

