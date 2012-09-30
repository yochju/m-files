function obj = AddReqDoubleVector(obj,argName)
obj.addRequired(argName,@(x) IsDouble(x)&&isvector(x));
end
