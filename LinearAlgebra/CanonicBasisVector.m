function E = CanonicBasisVector(i, n, varargin)
%% Computes the i-th canonical basis vector of length n.
%
% E = CanonicBasisVector(i, n, sparse)
%
% Input Parameters (required):
%
% i : Position of the 1. (integer)
% n : Length of the vector. (integer)
%
% Input parameters (optional):
%
% sparse : whether output should be sparse. (boolean, default = false)
%
% Output parameters:
%
% E : the i-th canonical Basis vector having a 1 at position i and 0 everywhere
%     else. (array)
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Computes the i-th canonical basis vector of length n. This vector has 1 at the
% i-th position and 0 everywhere else.
%
% Example:
%
% CanonicBasisVector(3,4) gives [0 ; 0 ; 1 ; 0 ].
%
% See also speye, eye.

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

% Last revision: 01.12.2012 20:58

%% Notes.

%% Parse input and output.

narginchk(2, 3);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('i', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive', '<=', n}, mfilename, 'i'));

parser.addRequired('n', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'n'));

parser.addOptional('sparse', false, @(x) validateattributes(x, {'logical'}, ...
    {'scalar'}, mfilename, 'sparse'));

parser.parse(i, n, varargin{:});
opts = parser.Results;

%% Run code.

if opts.sparse
    E = sparse(i,1,1,n,1);
else
    E = zeros(n,1);
    E(i) = 1;
end

end
