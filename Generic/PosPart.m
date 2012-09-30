function y = PosPart(x)
% Returns the Maximum between x and 0.
%
% The function is identical to subplus.
%
% Example
% PosPart(linspace(-10,10,100))
%
% See also subplus.

% Copyright (c) 2011 Laurent Hoeltgen <hoeltgman@gmail.com>
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

assert(isvector(x)||isscalar(x));
if isrow(x)
    y = max([ zeros(size(x)) ; x ]);
elseif iscolumn(x)
    y = max([ zeros(size(x')) ; x'])';
elseif isscalar(x)
    y = max([ x 0 ]);
end
end