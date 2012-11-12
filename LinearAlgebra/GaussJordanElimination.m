function x = GaussJordanElimination(A, b, varargin)
%% Perform Gauß Jordan elimination with possible partial pivoting.
%
% x = GaussJordanElimination(A, b, varargin)
%
% Input parameters (required):
%
% A : system matrix (array)
% b : righthand sides to solve system for. If b is a matrix, system is solved
%     for every column. (array)
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% pivot : whether to perform partial pivoting. Default is true. (boolean)
%
% Output parameters:
%
% x : solution(s) of the considered linear systems.
%
% Output parameters (optional):
%
%
%
% Description:
%
% Solves the linear system Ax=b using a Gauss Jordan elimination with partial
% pivoting.
%
% Example:
%
% Solve linear system for several righthand sides.
%
% T = randi(10,[3,3]);
% A = T'*T + 0.5*eye(3);
% b = randi(10,[3,1]);
% GaussJordanElimination(A,[b 2*b.^2])
%
% See also rref

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

% Last revision on: 12.11.2012 22:00

%% Parse input.

narginchk(2, 4);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

% System Matrix
parser.addRequired('A', ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'A'));

% Righthand side. Can be a matrix too.
parser.addRequired('b', ...
    @(x) validateattributes(x, {'numeric'}, ...
    {'2d', 'nonempty', 'nonnan', 'finite'}, ...
    mfilename, 'b'));

% Initial guess. If non is specified we initialise with 0.
parser.addParamValue('pivot', true, ...
    @(x) validateattributes(x, {'logical'}, {'scalar'}, mfilename, 'pivot'));

parser.parse(A, b, varargin{:})
opts = parser.Results;

% TODO: Check when system is over-/underdetermined. Maybe return basis of null
% space?

n = size(A,2);
D = [ A b ];

for k = 1:n
    if opts.pivot
        % Find row with pivoting element.
        r = (k-1) + find(abs(D(k:end,k))==max(abs(D(k:end,k))), 1, 'first');
        % Swap lines.
        temp = D(k,:);
        D(k,:) = D(r,:);
        D(r,:) = temp;
    end
    % Perform solving step.
    m = D(1:end~=k,k)/D(k,k);
    D(1:end~=k,k:end) = D(1:end~=k,k:end) - m*D(k,k:end);
end

x = D(:,(n+1):end)./kron(ones(1,size(b,2)),diag(D,0));
end
