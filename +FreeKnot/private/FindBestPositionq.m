function p = FindBestPositionq(V,x,pos)
% [ p ] = FindBestPositionq(V,x,pos)
% Looks for the best approximation of the scalar x inside the vector V and
% returns by default the position of the first occurence. This behaviour can
% be overriden by providing a thrid parameter which may be either 'first' or
% 'last' to return the respective occurence. This method is faster then
% FindBestPosition, however it does not perform any error checking.
%
% Usage: [ p ] = FindBestPositionq(V,x,pos)
% V   : the search space.
% x   : the value to be found.
% pos : if 'first' the first occurence is returned. If 'last' it returns the
%       last occurence.
% p   : the position of the best approximation to x.

% Copyright (c) 2011 Laurent Hoeltgen <hoeltgen@mia.uni-saarland.de>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
% MA 02110-1301, USA.

error(nargchk(2,3,nargin));

if nargin == 2
    pos = 'first';
end

if x >= max(V)
    p = length(V);
elseif x <= min(V)
    p = 1;
else
    temp = unique(V);
    p = round(interp1q(temp, [1:length(temp)]' , x ));
    p = find( V==temp(p) , 1 , pos );
end
end
