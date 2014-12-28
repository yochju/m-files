function [M, varargout] = LaplaceM(r,c,varargin)
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
% Computes the matrix corresponding to the Laplace operator. The discretisation
% is based on separable finite difference schemes (which can be specified
% through the options). The returned matrix is sparse. Boundary conditions can
% be specified through optional parameters. Accepted values are 'Neumann' or
% 'Dirichlet'. Default is the same as for FiniteDiff1DM. Note that the x-axis
% on a 2D signal is assumed to be going from left to right and the y-axis from
% top to bottom.
%
% Example
%
% Compute laplacian of a 3x5 Signal with row-wise numbering and Dirichlet 
% boundaries along rows (x-axis) and Neumann conditions along columns (y-axis)
%
% LaplaceM(3, 5, 'labeling', 'row', 'boundaryR', 'Dirichlet')
%
% See also DiffFilter1D, FiniteDiff1DM, GradientM

% Copyright 2012-2014 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 28.12.2014 19:47

%% Notes

%% Parse input and output.

narginchk(2, 16);
nargoutchk(0, 2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('r', @(x) validateattributes (x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'r'));

parser.addRequired('c', @(x) validateattributes (x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'c'));

parser.addParamValue('boundaryR', 'Neumann', ...
    @(x) strcmpi (x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundaryR')));

parser.addParamValue('boundaryC', 'Neumann', ...
    @(x) strcmpi (x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundaryC')));

parser.addParamValue('knotsR', [-1 0 1], @(x) validateattributes (x, ...
    {'numeric'}, {'vector', 'integer'}, mfilename, 'knotsR'));

parser.addParamValue('knotsC', [-1 0 1], @(x) validateattributes (x, ...
    {'numeric'}, {'vector', 'integer'}, mfilename, 'knotsC'));

parser.addParamValue('optsR', struct(), @(x) validateattributes (x, ...
    {'struct'}, {}, mfilename, 'optsR'));

parser.addParamValue('optsC', struct(), @(x) validateattributes (x, ...
    {'struct'}, {}, mfilename, 'optsC'));

parser.addParamValue('labeling', 'col', ...
    @(x) strcmpi(x, validatestring (x, {'col', 'row'}, mfilename, ...
    'labeling')));

parser.parse(r, c, varargin{:});
opts = parser.Results;

%% Run code.

if nargout < 2
    % Applies derivatives along rows (e.g. signals of length c)
    MR = FiniteDiff1DM (c, opts.knotsR, 2, 'boundary', opts.boundaryR, ...
        opts.optsR);
    % Applies derivatives along columns (e.g. signals of length r)
    MC = FiniteDiff1DM (r, opts.knotsC, 2, 'boundary', opts.boundaryC, ...
        opts.optsC);
    if r == 1
        % 2D/1D Signal consisting of a single row.
        M = MR;
    elseif c == 1
        % 2D/1D Signal consisting of a single column.
        M = MC;
    else
        % M = kron(Dxx,I) + kron(I,Dyy)
        if strcmpi (opts.labeling, 'col')
            M = KroneckerSum (MR, MC);
        else
            M = KroneckerSum (MC, MR);
        end
    end
else
    [MR, consR] = FiniteDiff1DM (c, opts.knotsR, 2, ...
        'boundary', opts.boundaryR, opts.optsR);
    [MC, consC] = FiniteDiff1DM (r, opts.knotsC, 2, ...
        'boundary', opts.boundaryC, opts.optsC);
    if r == 1
        % 2D/1D Signal consisting of a single row.
        M = MR;
        varargout{1} = consR;
    elseif c == 1
        % 2D/1D Signal consisting of a single column.
        M = MC;
        varargout{1} = consC;
    else
        % M = kron (Dxx, I) + kron (I, Dyy)
        if strcmpi (opts.labeling, 'col')
            M = KroneckerSum (MR, MC);
        else
            M = KroneckerSum (MC, MR);
        end
        varargout{1} = min ([consR, consC]);
    end
end

end
