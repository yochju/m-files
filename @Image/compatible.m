function bool = compatible(obj1,obj2)
error(nargchk(2, 2, nargin));
error(nargoutchk(0, 1, nargout));

parser = inputParser;

parser.addRequired('obj1', ...
    @(x) validateattributes( x, ...
    {'Image'}, ...
    {'scalar'}, ...
    'compatible', 'obj1'));

parser.addRequired('obj2', ...
    @(x) validateattributes( x, ...
    {'Image'}, ...
    {'scalar'}, ...
    'compatible', 'obj2'));

parser.parse(obj1,obj2);
parameters = parser.Results;

[nr1 nc1 c1] = parameters.obj1.size();
pType1 = parameters.obj1.pixelType();

[nr2 nc2 c2] = parameters.obj2.size();
pType2 = parameters.obj2.pixelType();

if ~strcmp(pType1,pType2)
    bool = false;
elseif ~isequal([nr1 nc1 c1],[nr2 nc2 c2])
    bool = false;
else
    bool = true;
end

end