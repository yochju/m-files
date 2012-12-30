function out = Mask(c)
%% Returns interpolation Mask as a diagonal matrix.
%
% out = Mask(c)
%
% Input parameters (required):
%
% c : mask indicating the positions where the dirichlet data should be applied.
%     (double array)
%
% Output parameters:
%
% out : sparse matrix containing the mask on its diagonal.
%
% Description:
%
% Evaluates the following PDE for given f, u and c:
%
% Returns the matrix corresponding to the mask that indicates the positions
% where the dirichlet data is positioned. The matrix is diagonal. If c is an
% array, the array is simply put on the diagonal. In case of a matrix (e.g.
% image data) c is labeled column-wise and the entries are placed in that order
% on the diagonal.
%
% Example:
% c = double(rand(100,100) > 0.6);
% s = Mask(c);
%
% See also spdiags, sparse

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the Free
% Software Foundation; either version 3 of the License, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
% for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 02.10.2012 11:55

narginchk(1, 1);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('c', @(x) ismatrix(x)&&IsDouble(x));

parser.parse(c)
opts = parser.Results;

% TODO: Allow passing options for thresholding.

out = spdiags( opts.c(:) , 0 , length(opts.c(:)), length(opts.c(:)) );

end
