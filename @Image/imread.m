function out = imread(obj,varargin)
pixel = builtin('imread',varargin{:});
out = Image(pixel,obj.padding);
end