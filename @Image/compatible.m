function bool = compatible(obj1, obj2)
%Image/compatible checks if two images have sime size and colorspace.
%
%   Input parameters (required):
%
% TODO
%
%   Input parameters (optional):
%
% TODO
%
%   Output parameters:
%
% TODO
%
%   Description:
%
% TODO
%
%   Example:
%
% TODO
%
%   See also size

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 18.07.2012 07:01

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