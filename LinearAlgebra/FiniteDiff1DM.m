function [M, varargout] = FiniteDiff1DM (len, knots, order, varargin)
%% Returns the matrix corresponding to a 1D finite difference scheme.
%
% M = FiniteDiff1DM (len, knots, order, varargin)
% [M cons] = FiniteDiff1DM (len, knots, order, varargin)
%
% Input Parameters (required):
%
% len   : length of the considered signal (positive integer)
% knots : grid positions for the stencil. (array of sorted integers)
% order : differentiation order. (positive integer)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% Any valid parameter for the the method DiffFilter1D. The parameters are passed
% down as-is.
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
% Computes the matrix corresponding to a finite difference scheme based on given
% knot points through a taylor expansion. knots can be a row or column vector.
% The returned matrix is sparse. Boundary conditions can be specified through
% optional parameters. Accepted values are 'Neumann' or 'Dirichlet'.
%
% Example
%
% Get standard finite difference matrix for second derivative with Dirichlet
% boundary conditions of signal of lenggth 10.
% FiniteDiff1DM(10,[-1 0 1],2,'GridSize',1.0,'Boundary','Dirichlet')
%
% See also DiffFilter1D.

% Copyright 2012 - 2014 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 27.12.2014 20:00

%% Notes

%% Parse input and output.

narginchk (3, 7);
nargoutchk (0, 2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired ('len', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'knots'));

parser.addRequired ('knots', @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'integer'}, mfilename, 'knots'));

parser.addRequired ('order', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'order'));

parser.addParamValue ('boundary', 'Neumann', ...
    @(x) strcmpi(x, validatestring(x, {'Dirichlet', 'Neumann'}, mfilename, ...
    'boundary')));

parser.parse ( len, knots, order, varargin{:});
opts = parser.Results;

%% Run code.

if nargout < 2
    coeffs = DiffFilter1D (knots, order, parser.Unmatched);
else
    [coeffs, cons] = DiffFilter1D (knots, order, parser.Unmatched);
    varargout{1} = cons;
end

% These are needed to pad the signal on every side by the correct amount.
Am = abs (min (knots));
AM = abs (max (knots));

% Determine the matrix.

% We first set up a matrix to a signal which is extended on both sides such that
% we do not have to worry about boundary conditions here. Those will be included
% in the next step by considering the respective padding.
temp = spdiags (repmat (coeffs, len, 1), knots+Am, len, len+Am+AM);

%% Take care of the boundary conditions.
switch opts.boundary
    case 'Neumann'
        % Corresponds to padding the original signal through mirroring. This
        % implies that we have to flip the overlaps and add them back onto the
        % matrix at the corresponding side.
        
        % Left boundary.
        temp(:, Am+1:2*Am) = temp(:, Am+1:2*Am) + fliplr (temp(:, 1:Am));
        
        % Right boundary
        temp(:, end-2*AM+1:end-AM) = temp(:, end-2*AM+1:end-AM) + ...
            fliplr (temp(:, end-AM+1:end));
        
        % Return the part of the matrix corresponding to the original signal.
        M = temp(:, Am+1:end-AM);
        
    case 'Dirichlet'
        % Corresponds to padding with 0. We simply ignore everything outside of
        % our domain.
        M = temp(:, Am+1:end-AM);
end

end
