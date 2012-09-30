function obj = AddOptDoubleArray(obj, argName, default)
obj.addOptional(argName, default, @IsDouble);
obj.numOpt = obj.numOpt + 1;
end
