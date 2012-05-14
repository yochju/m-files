function V = CircShiftM(n,p)
%% Returns the circular shift matrix of order n.
%
% V = CircShiftM(n)
% V = CircShiftM(n,p)
%
% The circular shift matrix of order n performs a shift on a given vector with a
% circular wrap around. shifts can be to the left (positive values of p) or to
% the right (negative values of p).
%
% Input parameters (required):
%
% n : Size of the matrix. (positive integer)
%
% Input parameters (optional):
%
% p : amount of positions to shift. (integer) (default = 1)
%
% Output parameters:
%
% V : The circular shift matrix of order n. (sparse matrix)
%
% Example
%
% n = 4;
% V = CircShiftM(n);
%
% See also circshift

% Copyright 2011,2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 2012/02/18 21:00

%% Comments and Remarks.

%% Check Input/Output parameters.

error(nargchk(1, 2, nargin));
error(nargoutchk(0, 1, nargout));

assert(isscalar(n), ...
    'LinearAlgebra:CircShiftM:BadInput', ...
    'Matrix order must be a single scalar value.');
assert( (floor(n)==ceil(n)) && (n>=1), ...
    'LinearAlgebra:CircShiftM:BadInput', ...
    'Matrix order must be a positive integer number.');

if nargin == 1
    p = 1;
else
    assert(isscalar(p), ...
        'LinearAlgebra:CircShiftM:BadInput', ...
        'Shift order must be a single scalar value.');
    assert(floor(p)==ceil(p), ...
       'LinearAlgebra:CircShiftM:BadInput', ...
       'Shift order must be an integer number.');
   % Since we assume the signal to be periodic, there exists for every specified
   % p a shift by p positions with 0 <= p < n.
   if (abs(p) >= n) || (-n <= p && p <= 0)
       p = mod(p,n);
   end
end

%% Set up the matrix.

V = sparse(1:n,[(p+1):n 1:p],ones(1,n),n,n);

end