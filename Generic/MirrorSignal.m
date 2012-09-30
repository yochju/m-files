function sOut = MirrorSignal( sIn , dim , repetitions)
% Mirrors a signal along dimension dim.
%
% MirrorSignal mirrors the complete signal a specified number of times along the
% specified dimension.
%
% Example
% MirrorSignal( 1:3 , 2 , 1 )
%
% See also PeriodicExtension

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

if mod(repetitions,2) == 1
    sOut = PeriodicExtension( flipdim(sIn,dim) , dim , 2*repetitions , true );
else
    sOut = PeriodicExtension( sIn , dim , 2*repetitions , true );
end
end