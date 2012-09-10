function r = IsSquarematrix(A)
%% Checks if input is a square matrix.
%
% r = IsSquarematrix(A)
%
% Verifies whether input is a square matrix.
%
% Input Parameters (required):
%
% A : test candidate. (arbitrary)
%
% Output Parameters
%
% r : result. (boolean)
%
% Example
%
% A = [1 2 ; 3 4];
% issquarematrix(A)
%
% See also ismatrix.

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

% Last revision: 10.09.2012 11:04

%% Comments and Remarks.
%

%% Check input parameters

narginchk(1, 1);
nargoutchk(0, 1);

%% Perform test

r = ismatrix(A) && (diff(size(A))==0);

end
