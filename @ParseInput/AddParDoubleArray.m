function obj = AddParDoubleArray(obj, argName, default)
obj.addParamValue(argName,default,@IsDouble);
obj.numPar = obj.numPar + 1;
end
