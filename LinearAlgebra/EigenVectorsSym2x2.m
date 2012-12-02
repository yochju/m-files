function out = EigenVectorsSym2x2(M)
%% Returns the normalised eigenvectors of a symmetric 2 times 2 matrix.

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

% Last revision on: 01.12.2012 21:40

%% Notes.

%% Parse input and output.

narginchk(1, 1);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('M', @(x) validateattributes(x, {'numeric'}, ...
    {'size', [2 2], 'nonsparse'}, mfilename, 'M'));

parser.parse(M);

ExcM = ExceptionMessage('Input', 'Input matrix must be symmetric.');
assert(IsSymmetric(M), ExcM.id, ExcM.message);

%% Run code.

a = M(1,1);
b = M(2,1);
c = M(2,2);

if abs(b) < 10*eps
    out = [1 0 ; 0 1];
else
    v1 = [ a-c-sqrt(4*b^2+(a-c)^2) ; 2*b ];
    v2 = [ a-c+sqrt(4*b^2+(a-c)^2) ; 2*b ];
    out = [ v1/norm(v1) v2/norm(v2) ];
end
end
