function [out] = Tensor2Stencil(a, b, c, alpha, beta)
%% Tensor2Stencil
%
% <SIGNATURE>
%
% Input parameters (required):
%
% -
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% -
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% -
%
% Output parameters:
%
% -
%
% Output parameters (optional):
%
% -
%
% Description:
%
% -
%
% Example:
%
% -
%
% See also

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: dd.mm.yyyy hh:mm

%% Notes

%% Parse input and output.

%% Run code.

out = cell(3,3);

out{1,1} = (beta-1)*b + alpha*(a+c);
out{1,2} = ((1-alpha)*c - alpha*a + beta*b) + ...
    ((1-alpha)*c - alpha*a + beta*b);
out{1,3} = (beta+1)*b + alpha*(a+c);

out{2,1} = ((1-alpha)*c - alpha*a + beta*b) + ...
    ((1-alpha)*c - alpha*a + beta*b);
out{2,2} = - ( ...
    ((1-alpha)*(a+c) - (beta-1)*b) + ...
    ((1-alpha)*(a+c) - (beta+1)*b) + ...
    ((1-alpha)*(a+c) - (beta+1)*b) + ...
    ((1-alpha)*(a+c) - (beta-1)*b) );
out{2,3} = ((1-alpha)*c - alpha*a + beta*b) + ...
    ((1-alpha)*c - alpha*a + beta*b);

out{3,1} = (beta+1)*b + alpha*(a+c);
out{3,2} = ((1-alpha)*c - alpha*a + beta*b) + ...
    ((1-alpha)*c - alpha*a + beta*b);
out{3,3} = (beta-1)*b + alpha*(a+c);

end

function out = InterPixelValue(in, xshift, yshift)

[nr, nc] = size(in);
[X Y] = meshgrid(1:nr, 1:nc);

out = interp2(X,Y,Z,X+xshift,X+yshift,'linear');

if xshift = -1
end
if xshift = 1
end
if yshift = -1
end
if yshift = 1
end

end
