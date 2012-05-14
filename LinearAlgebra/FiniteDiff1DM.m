function [M cons] = FiniteDiff1DM(len,knots,order,varargin)
%% Returns the matrix corresponding to a 1D finite difference scheme.
%
% M = FiniteDiff1DM(len,knots,order,varargin)
% [M cons] = FiniteDiff1DM(len,knots,order,varargin)
%
% Computes the matrix corresponding to a finite difference scheme based on given
% knot points through a taylor expansion. knots can be a row or column vector.
% The returned matrix is sparse. Boundary conditions can be specified through
% optional parameters. Accepted values are 'Neumann' or 'Dirichlet'.
%
% Input Parameters (required):
%
% len   : length of the considered signal (positive integer)
% knots : grid positions for the stencil. (array of sorted integers)
% order : differentiation order. (positive integer)
%
% Input Parameters (pairs), (optional):
%
% 'GridSize'  : size of the grid. (positive double) (default = 1.0)
% 'Boundary'  : boundary condition. (string) (default = 'Neumann')
% 'Tolerance' : tolerance when checking the consistency order. (default 100*eps)
%
% Output Parameters
%
% M    : Matrix of the corresponding scheme. (sparse matrix)
% cons : consistency order of the obtained scheme. (integer)
%
% Example
%
% Get standard finite difference matrix for second derivative with Dirichlet
% boundary conditions of signal of lenggth 10.
% FiniteDiff1DM(10,[-1 0 1],2,'GridSize',1.0,'Boundary','Dirichlet')
%
% See also DiffFilter1DM.

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

%% Check input parameters

error(nargchk(3, 9, nargin));
error(nargoutchk(0, 2, nargout));

optargin = size(varargin,2);
stdargin = nargin - optargin;

assert( stdargin == 3, ...
    'LinearAlgebra:FiniteDiff1DM:BadInput', ...
    ['The first three parameters must be signal length, the knot sites and ' ...
     'the differentiation order.']);
assert( mod(optargin,2)==0, ...
    'LinearAlgebra:FiniteDiff1DM:BadInput', ...
    'Optional arguments must come in pairs.');

BoundCond = 'Neumann';
GridS = 1.0;
Tol = 100*eps;
for i = 1:2:optargin
    switch varargin{i}
        case 'GridSize'
            GridS = varargin{i+1};
        case 'Boundary'
            BoundCond = varargin{i+1};
            assert( any(strcmp(BoundCond, {'Dirichlet', 'Neumann'}) ) , ...
                'LinearAlgebra:FiniteDiff1DM:BadInput', ...
                'Unknown boundary condition specified.');
        case 'Tolerance'
            Tol = varargin{i+1};
    end
end

%% Set up internal variables.

if nargout < 2
    coeffs = DiffFilter1D(knots, order, ...
        'GridSize', GridS, 'Tolerance', Tol);
else
    [coeffs cons] = DiffFilter1D(knots, order, ...
        'GridSize', GridS, 'Tolerance', Tol);
end

% These are needed to pad the signal on every side by the correct amount.
Am = abs(min(knots));
AM = abs(max(knots));

%% Determine the matrix.

% We first set up a matrix to a signal which is extended on both sides such that
% we do not have to worry about boundary conditions here. Those will be included
% in the next step by considering the respective padding.
temp = spdiags(repmat(coeffs,len,1),knots+Am,len,len+Am+AM);

%% Take care of the boundary conditions.
switch BoundCond
    case 'Neumann'
        % Corresponds to padding the original signal through mirroring. This
        % implies that we have to flip the overlaps and add them back onto the
        % matrix at the corresponding side.
        
        % Left boundary.
        temp(:,Am+1:2*Am) = temp(:,Am+1:2*Am) + fliplr(temp(:,1:Am));
        
        % Right boundary
        temp(:,end-2*AM+1:end-AM) = temp(:,end-2*AM+1:end-AM) + ...
            fliplr(temp(:,end-AM+1:end));
        
        % Return the part of the matrix corresponding to the original signal.
        M = temp(:,Am+1:end-AM);
        
    case 'Dirichlet'
        % Corresponds to padding with 0. We simply ignore everything outside of
        % our domain.
        M = temp(:,Am+1:end-AM);
end

end