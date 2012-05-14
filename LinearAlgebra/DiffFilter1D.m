function [coeffs, cons] = DiffFilter1D(knots,order,varargin)
%% Returns the coefficients of a 1D finite difference scheme.
%
% coeffs = DiffFilter1D(knots,order,varargin)
% [coeffs, cons] = DiffFilter1D(knots,order,varargin)
%
% Determines the coefficients of a finite difference scheme based on the given
% knot points through a taylor expansion. knots can be a row or column vector,
% but the function always returns the coefficients in a row vector.
%
% Input Parameters (required):
%
% knots : grid positions for the stencil. (array of sorted integers)
% order : differentiation order. (positive integer)
%
% Input Parameters (pairs), (optional):
%
% 'GridSize'  : size of the grid. (positive double) (default = 1.0)
% 'Tolerance' : tolerance when checking the consistency order. (default 100*eps)
%
% Output Parameters
%
% coeffs : coefficients of the corresponding knots. (array)
% cons   : consistency order of the obtained scheme. (integer)
%
% Example
%
% Get standard finite difference scheme for second derivative.
% DiffFilter([-1 0 1],2,'GridSize',1.0)
%
% See also FiniteDiff1DM.

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

% Last revision: 2012/02/18 20:00

%% Comments and Remarks.
%
% TODO: Check if the knots really need to be sorted.
% TODO: Are these knots valid: [-4 -3 -2]? Is the implementation correct then?

%% Check input parameters

error(nargchk(2, 6, nargin));
error(nargoutchk(0, 2, nargout));

optargin = size(varargin,2);
stdargin = nargin - optargin;

assert( stdargin == 2, ...
    'LinearAlgebra:DiffFilter1D:BadInput', ...
    'The first two parameters must be the image and the quality threshold.');
assert( mod(optargin,2)==0, ...
    'LinearAlgebra:DiffFilter1D:BadInput', ...
    'Optional arguments must come in pairs.');
assert( all(knots==sort(knots)), ...
    'LinearAlgebra:DiffFilter1D:BadInput', ...
    'Knot sites must be sorted (ascending).');
assert( order > 0, ...
    'LinearAlgebra:DiffFilter1D:BadInput', ...
    'Differentiation order must be at least 1.');
assert( length(knots(:)) > order, ...
    'LinearAlgebra:DiffFilter1D:BadInput', ...
    'At least one more knot as the differentiation order is required.');

h = 1.0;
limit = 100*eps;
for i = 1:2:optargin
    switch varargin{i}
        case 'GridSize'
            h = varargin{i+1};
            assert( h > 0, ...
                'LinearAlgebra:DiffFilter1D:BadInput', ...
                'Grid size must be a positive value.');
        case 'Tolerance'
            limit = varargin{i+1};
            assert( limit > 0, ...
                'LinearAlgebra:DiffFilter1D:BadInput', ...
                'Specified tolerance must be positive.');
    end
end

%% Set up internal variables.

x = knots(:);
n = length(x);
taylor = @(x,y) x.^y/factorial(y);

%% Determine the stencil.

% Matrix containing the coefficients of the Taylor expansion at the given knot
% sites.
M = bsxfun(taylor,x,0:(n-1))';
% Righthand side of the linear system indicating the considered derivative.
b = zeros(n,1);
b(min(order,n-1)+1)=1;
% The solution of the linear system contains the desired coefficients.
coeffs = ((M\b)'/h^order);

%% Determine the consistency order if required.

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
    if ~(i==order&&abs(sum(coeffs.*((h*knots).^i)/factorial(i))-1) <= limit)
        warning('LinearAlgebra:DiffFilter1D:BadApproximation', ...
            'Scheme does not approximate desired derivative.');
    end
    
    %% Now check consistency.
    
    i = i+1;
    
    % Now we check how many terms after the derivative are still 0 when we plug
    % in the Taylor expansion.
    while abs(sum(coeffs.*((h*knots).^i)/factorial(i))) <= limit
        i = i + 1;
    end
    
    cons = i - order;
    
    if cons<=0
        warning('LinearAlgebra:DiffFilter1D:InconsistentScheme', ...
            'Scheme is not consistent.');
    end
    
end

end