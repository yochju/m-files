function  [y varargout]  = Threshold( x , t )
%% Thresholds input x with respect to t.
%
% [y, p, v]  = Threshold( x , t )
%
% Input parameters (required):
%
% x : vector to apply the thresholding on (array).
% t : threshold (scalar).
%
% Output parameters:
%
% y : vector of same size as x, containing 1 if the entry was strictly larger
%     than t or 0 else.
% p : the positions of the indices that exceed t.
% v : the values found at positions p.
%
% Description:
%
% Finds all values in x that are smaller or equal in absolute value than t.
%
% Example:
%
% x = [-3 -1 0 1 2 ]
% y = Threshold(x,1.5)
%
% yields y = [1 0 0 0 1].
%
% See also max.

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

% Last revision: 2012/09/06 14:10

%% Check input parameters

narginchk(2, 2);
nargoutchk(0, 3);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('x', @(x) ismatrix(x));
parser.addRequired('t', @(x) isscalar(x));

parser.parse(x,t);
opts = parser.Results;

ExcM = ExceptionMessage('BadArg', '', ...
    'Negative thresholding value encountered.');

% TODO: The id is not recognised. Because it contains no :? See doc.
%warning(ExcM.id,ExcM.message);
if opts.t < 0
    warning(ExcM.message);
end

%% Compute thresholding

y = sign( max( abs(opts.x) - opts.t , 0 ) );

if nargout >= 2
    varargout{1} = find(y);
end

if nargout >= 3
    varargout{2} = opts.x(y==1);
end

end
