classdef AttackExpertise < uint16
    % See ISO/SAE 21434:2021 G.2.2.2.
    enumeration
        EX_Layman(0), % Unknowledgeable compared to experts or proficient persons, with no particular expertise
        EX_Proficient(3), % Knowledgeable in that they are familiar with the security behaviour of the product or system type.
        EX_OneExpert(6), % Familiar with the underlying algorithms, protocols, hardware, structures, security behaviour, principles and concepts of security employed, techniques and tools for the definition of new attacks, cryptography, classical attacks for the product type, attack methods, etc. implemented in the product or system type.
        EX_MultipleExperts(8) % Different fields of expertise are required at an expert level for distinct steps of an attack.
    end
end

