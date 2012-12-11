function [M varargout] = LaplaceM(r,c,varargin)
%% Returns the matrix corresponding to the Laplace operator.
%
% M = LaplaceM(r, c, ...)
% [M cons] = LaplaceM(r, c, ...)
%
% Input Parameters (required):
%
% r : number of rows of the signal. (positive integer)
% c : number of columns of the signal. (positive integer)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% knotsR : Knots to be considered for the rows. (array of sorted integers,
%          default = [-1 0 1])
% knotsC : Knots to be considered for the columns. (array of sorted integers,
%          default = [-1 0 1])
% optsR  : options to be passed to FiniteDiff1DM for the row computation.
%          (struct, default = struct())
% optsC  : options to be passed to FiniteDiff1DM for the column computation.
%          (struct, default = struct())
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% -
%
% Output Parameters:
%
% M : Matrix of the corresponding scheme. (sparse matrix)
%
% Output parameters (optional):
%
% cons : consistency order of the obtained scheme. (integer)
%
% Description:
%
% Computes the matrix corresponding to the Laplace operator. The discretisation
% is based on separable finite difference schemes (which can be specified
% through the options). The returned matrix is sparse. Boundary conditions can
% be specified through optional parameters. Accepted values are 'Neumann' or
% 'Dirichlet'. Default is the same as for FiniteDiff1DM.
%
% Example
%
% LaplaceM(4,5);
%
% See also DiffFilter1D, FiniteDiff1DM

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

% Last revision: 11.12.2012 15:30

%% Notes
%
% The implementation assumes that the points are number row-wise. This is in
% conflict with the standard numbering scheme in MATLAB, which runs column-wise
% over a matrix.
% TODO: implement an option to make this behavior changeable.

%% Parse input and output.

narginchk(2, 10);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('r', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'r'));

parser.addRequired('c', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'c'));

parser.addParamValue('knotsR', [-1 0 1], @(x) validateattributes(x, ...
    {'numeric'}, {'vector', 'integer'}, mfilename, 'knotsR'));

parser.addParamValue('knotsC', [-1 0 1], @(x) validateattributes(x, ...
    {'numeric'}, {'vector', 'integer'}, mfilename, 'knotsC'));

parser.addParamValue('optsR', struct(), @(x) validateattributes(x, ...
    {'struct'}, {}, mfilename, 'optsR'));

parser.addParamValue('optsC', struct(), @(x) validateattributes(x, ...
    {'struct'}, {}, mfilename, 'optsC'));

parser.parse(r, c, varargin{:});
opts = parser.Results;

%% Run code.

if nargout < 2
    MR = FiniteDiff1DM(c, opts.knotsR, 2, 'optsFilter', opts.optsR);
    MC = FiniteDiff1DM(r, opts.knotsC, 2, 'optsFilter', opts.optsC);
    if r == 1
        M = MR;
    elseif c == 1
        M = MC;
    else
        M = KroneckerSum(MC,MR);
    end
else
    [MR consR] = FiniteDiff1DM(c, opts.knotsR, 2, 'optsFilter', opts.optsR);
    [MC consC] = FiniteDiff1DM(r, opts.knotsC, 2, 'optsFilter', opts.optsC);
    if r == 1
        M = MR;
        varargout{1} = consR;
    elseif c == 1
        M = MC;
        varargout{1} = consC;
    else
        M = KroneckerSum(MC,MR);
        varargout{1} = min([consR, consC]);
    end
end

end
