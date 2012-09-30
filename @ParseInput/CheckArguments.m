function obj = CheckArguments(obj,numIn,numOut,varargin)
obj.CheckNumInput(numIn);
obj.CheckNumOutput(numOut);
obj.parse(varargin{:});
end
