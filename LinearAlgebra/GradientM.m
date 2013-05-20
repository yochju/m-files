function [M varargout] = GradientM(r, c, varargin)
%% Returns the matrix corresponding to the Gradient operator.
%
% M = GradientM(r, c, varargin)
% [M cons] = GradientM(r, c, varargin)
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
% boundaryR : boundary condition for rows. (string, default = 'Neumann')
% boundaryC : boundary condition for columns. (string, default = 'Neumann')
% knotsR    : Knots to be considered for the rows. (array of sorted integers,
%             default = [-1 0 1])
% knotsC    : Knots to be considered for the columns. (array of sorted integers,
%             default = [-1 0 1])
% optsR     : options to be passed to DiffFilter1D for the row computation.
%             (struct, default = struct())
% optsC     : options to be passed to DiffFilter1D for the column computation.
%             (struct, default = struct())
% labeling  : how the pixels in the image are labelled. Either 'row' for rowwise
%             numbering or 'col' for columnwise numbering. The default is to
%             number the signal entries columnwise (e.g. matlab default)
%             (string, default = 'col')
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
% Computes the matrix corresponding to the Gradient operator. The discretisation
% is based on separable finite difference schemes (which can be specified
% through the options). The returned matrix is sparse. Boundary conditions can
% be specified through optional parameters. Accepted values are 'Neumann' or
% 'Dirichlet'. Note that the Boundary conditions must be the same for the x and
% for the y derivative. The output Matrix computes first all the derivatives in
% x direction and then all the derivatives in y direction. Note that the x-axis
% on a 2D signal is assumed to be going from left to right and the y-axis from
% top to bottom.
%
% Example:
%
% Compute gradient of a 3x5 Signal with row-wise numbering and Dirichlet 
% boundaries along rows (x-axis) and Neumann conditions along columns (y-axis)
%
% GradientM(3, 5, 'labeling', 'row', 'boundaryR', 'Dirichlet')
%
% See also LaplaceM, DiffFilter1D, FiniteDiff1DM.

% Copyright 2012, 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 20.05.2013 11:24

%% Notes

%% Parse input and output.

narginchk(2, 16);
nargoutchk(0, 2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('r', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'r'));

parser.addRequired('c', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'c'));

parser.addParamValue('boundaryR', 'Neumann', ...
    @(x) strcmpi(x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundaryR')));

parser.addParamValue('boundaryC', 'Neumann', ...
    @(x) strcmpi(x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundaryC')));

parser.addParamValue('knotsR', [0 1], @(x) validateattributes(x, ...
    {'numeric'}, {'vector', 'integer'}, mfilename, 'knotsR'));

parser.addParamValue('knotsC', [0 1], @(x) validateattributes(x, ...
    {'numeric'}, {'vector', 'integer'}, mfilename, 'knotsC'));

parser.addParamValue('optsR', struct(), @(x) validateattributes(x, ...
    {'struct'}, {}, mfilename, 'optsR'));

parser.addParamValue('optsC', struct(), @(x) validateattributes(x, ...
    {'struct'}, {}, mfilename, 'optsC'));

parser.addParamValue('labeling', 'col', ...
    @(x) strcmpi(x, validatestring(x, {'col', 'row'}, mfilename, ...
    'labeling')));

parser.parse(r, c, varargin{:});
opts = parser.Results;

%% Run code.

if nargout < 2
    MR = FiniteDiff1DM(c, opts.knotsR, 1, 'boundary', opts.boundaryR, ...
        'optsFilter', opts.optsR);
    MC = FiniteDiff1DM(r, opts.knotsC, 1, 'boundary', opts.boundaryC, ...
        'optsFilter', opts.optsC);
    if r == 1
        M = MR;
    elseif c == 1
        M = MC;
    else
        if strcmpi(opts.labeling,'col')
            M = [ kron(MR,speye(r,r)) ; kron(speye(c,c),MC) ];
        else
            M = [ kron(speye(r,r),MR) ; kron(MC,speye(c,c)) ];
        end
    end
else
    [MR consR] = FiniteDiff1DM(c, opts.knotsR, 1, ...
        'boundary', opts.boundaryR, ...
        'optsFilter', opts.optsR);
    [MC consC] = FiniteDiff1DM(r, opts.knotsC, 1, ...
        'boundary', opts.boundaryC, ...
        'optsFilter', opts.optsC);
    if r == 1
        M = MR;
        varargout{1} = consR;
    elseif c == 1
        M = MC;
        varargout{1} = consC;
    else
        if strcmpi(opts.labeling,'col')
            M = [ kron(MR,speye(r,r)) ; kron(speye(c,c),MC) ];
        else
            M = [ kron(speye(r,r),MR) ; kron(MC,speye(c,c)) ];
        end
        varargout{1} = min([consR, consC]);
    end
    
end
