function sOut = MirrorBounds( sIn , dim , len)
% Mirrors the boundary of a signal along dimension dim.
%
% MirrorBounds mirrors the boundary of a signal along the specified dimension.
%
% Example
% MirrorBounds( 1:3 , 1 , 1 )
%
% See also PeriodicExtension, MirrorSignal
%
% TODO: it does not work along all dimensions.

% Copyright 2011 Laurent Hoeltgen <hoeltgman@gmail.com>
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

assert( len <= size(sIn,dim) );
sTemp = MirrorSignal(sIn,dim,1);
[sTemp,perm,nshifts] = shiftdata(sTemp,dim);
sOut = unshiftdata(sTemp( (size(sIn,dim)+1-len):(size(sIn,dim)*2+len)), ...
    perm,nshifts);
end