function out = MeanFilter(in, size, varargin)
%% Applies a mean filter of size (2*r+1 x 2*c+1) on imput.

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

% Last revision on: 19.10.2012 21:00

narginchk(2, 6);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addRequired('size', @(x) isvector(x)&&all(x>0)&&all(IsInteger(x)) );

parser.addParamValue('weights', ones(2*size+1)/(prod(2*size+1)), ...
    @(x) validateattributes( x, ...
    {'numeric'}, ...
    {'nonempty', 'finite', 'nonnan'}, ...
    mfilename, 'left') );

parser.addParamValue('its', 1 , @(x) isscalar(x)&&IsInteger(x)&&(x>=0) );

parser.parse(in,size,varargin{:});
opts = parser.Results;

out = opts.in;
for i = 1:opts.its
    % TODO: allow other boundary extensions.
    out = convn(MirrorEdges(out, opts.size), opts.weights, 'valid');
end

end
