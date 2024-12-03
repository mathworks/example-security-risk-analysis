function loHi = getEnumRange(one_enum)
    % get the range of the values underlying an enum
    % Copyright 2023-2024, The MathWorks, Inc.
    enumValues = double(enumeration(one_enum));
    loHi = [min(enumValues), max(enumValues)];
end