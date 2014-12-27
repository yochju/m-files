function [coeffs, varargout] = DiffFilter1D (knots, order, varargin)
%% Returns the coefficients of a 1D finite difference scheme.
%
% [coeffs] = DiffFilter1D (knots, order, varargin)
% [coeffs, cons] = DiffFilter1D(knots, order, varargin)
%
% Input Parameters (required):
%
% knots : Grid positions for the stencil. (array of sorted integers)
% order : Differentiation order. (positive integer)
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% gridSize  : size of the grid. (positive scalar, default = 1.0)
% tolerance : tolerance when checking the consistency order. (default 1e-12)
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% -
%
% Output Parameters
%
% coeffs : coefficients of the corresponding knots. (array)
%
% Output parameters (optional):
%
% cons : consistency order of the obtained scheme. (integer)
%
% Description:
%
% Determines the coefficients of a finite difference scheme based on the given
% knot points through a taylor expansion. knots can be a row or column vector,
% but the function always returns the coefficients in a row vector.
%
% Example
%
% Get standard finite difference scheme for second derivative.
% DiffFilter1D([-1 0 1], 2, 'GridSize', 1.0)
%
% See also FiniteDiff1DM.

% Copyright 2014 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 27.12.2014 20:15

%% Notes

% TODO: Check if the knots really need to be sorted.
% TODO: Are these knots valid: [-4 -3 -2]? Is the implementation correct then?

%% Parse input and output.

narginchk(2, 6);
nargoutchk(0, 2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = false;
parser.StructExpand = true;

parser.addRequired('knots', @(x) validateattributes(x, {'numeric'}, ...
    {'vector', 'integer'}, mfilename, 'knots'));

parser.addRequired('order', @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}, mfilename, 'order'));

parser.addParamValue('gridSize', 1, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','positive'}, ...
    mfilename, 'gridSize'));

parser.addParamValue('tolerance', 1e-12, @(x) validateattributes(x, ...
    {'numeric'}, {'scalar','nonempty','finite','positive'}, ...
    mfilename, 'tolerance'));

parser.parse( knots, order, varargin{:});
opts = parser.Results;

MExc = ExceptionMessage('Input');

if ~isequal(knots, sort(knots))
    MExc.message = 'Knot sites are not sorted. Will be sorted now.';
    warning(MExc.id, MExc.message);
    knots = sort(knots);
end

if numel(knots(:)) <= order,
    MExc.message = ['At least one more knot as the differentiation ' ...
        'order is required.'];
    error(MExc.id, MExc.message);
end

h = opts.gridSize;
limit = opts.tolerance;

%% Run code.

% Set up internal variables.

x = knots(:);
n = numel(x);
taylor = @(x,y) x.^y/factorial(y);

% Determine the stencil.

% Matrix containing the coefficients of the Taylor expansion at the given knot
% sites.
M = bsxfun(taylor,x,0:(n-1))';
% Righthand side of the linear system indicating the considered derivative.
b = zeros(n,1);
b(min(order,n-1)+1)=1;
% The solution of the linear system contains the desired coefficients.
if IsConsistent(M, b)
    coeffs = ((M\b)'/h^order);
else
    ExcM = ExceptionMessage('Input', 'message', ...
        'Stencil leads to a linear system which cannot be solved.');
    error(ExcM.id, ExcM.message);
end


% Determine the consistency order if required.

if nargout == 2
    %% Check that scheme approximates the correct derivative.
    
    i = 0;
    
    % Plugging in the Taylor expansion must yield 0 for every term smaller than
    % the derivative we want to approximate.
    while abs(sum(coeffs.*((h*knots).^i)/factorial(i))) <= limit
        i = i + 1;
    end
    
    % The term corresponding to the derivative must be 1. Otherwise the scheme
    % does not approximate the desired derivative.
    if ~(i==order && abs(sum(coeffs.*((h*knots).^i)/factorial(i))-1) <= limit)
        MExc = ExceptionMessage('Internal', ...
            'message', 'Unable to approximate desired derivative.');
        error(MExc.id, MExc.message);
    end
    
    % Now check consistency.
    
    i = i+1;
    
    % Now we check how many terms after the derivative are still 0 when we plug
    % in the Taylor expansion.
    while abs(sum(coeffs.*((h*knots).^i)/factorial(i))) <= limit
        i = i + 1;
    end
    
    cons = i - order;
    
    if cons<=0
        MExc = ExceptionMessage('Internal', ...
            'message', 'Scheme may not be consistent.');
        warning(MExc.id, MExc.message);
    end
    
    varargout{1} = cons;
    
end

end
