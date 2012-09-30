function obj = AddReqDoubleArray(obj, argName)
obj.addRequired(argName,@IsDouble);
obj.numReq = obj.numReq + 1;
end
