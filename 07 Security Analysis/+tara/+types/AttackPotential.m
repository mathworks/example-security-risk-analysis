classdef AttackPotential
    %ATTACKPOTENTIAL See ISO/SAE 21434:2021 G.2. and ISO/IEC 18045.
    
    properties
        ElapsedTime tara.types.AttackElapsedTime
        Expertise tara.types.AttackExpertise
        Knowledge tara.types.AttackKnowledge
        Window tara.types.AttackWindow
        Equipment tara.types.AttackEquipment
    end
    
    methods
        function obj = AttackPotential(et, ex, kn, wi, eq)
            getDefault = @(typename) getfield(enumeration(typename),{1});
            if nargin < 5
                eq = getDefault('tara.types.AttackEquipment');
            end
            if nargin < 4
                wi = getDefault('tara.types.AttackWindow');
            end
            if nargin < 3
                kn = getDefault('tara.types.AttackKnowledge');
            end
            if nargin < 2
                ex = getDefault('tara.types.AttackExpertise');
            end
            if nargin < 1
                et = getDefault('tara.types.AttackElapsedTime');
            end
            obj.ElapsedTime = et;
            obj.Expertise = ex;
            obj.Knowledge = kn;
            obj.Window = wi;
            obj.Equipment = eq;
        end     
        function val = getValue(obj)
            val = obj.ElapsedTime + obj.Equipment + obj.Expertise + ...
                  obj.Knowledge + obj.Window;
            val = max(min(val, 19),0);
        end
    end
end

