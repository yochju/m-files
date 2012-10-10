function out = MirrorEdges(in, varargin)
%% Mirrors image edges in each direction by s pixel.
%
% out = MirrorEdges(in, ...)
%
% Input parameters (required):
%
% in : input image (array).
%
% Input parameters (optional):
%
% size : size of dummy boundaries (scalar, default = [1 1] for 2d, [0 1] for
%        row- and [1 0] for column arrays as input.).
%
% Output parameters
%
% out : image with mirrored edges.
%
% Description
%
% Adds a dummy boundary around an input image by mirroring the data. Does not
% work for arrays with more than 2 dimensions. If input is a 1D signal (e.g. a
% row or column vector, then, the mirroring ins applied only on the endpoints if
% the optional parameter is omitted. For 2D signals, the default behavior is to
% apply the mirroring along every edge.
%
% Example:
% I = rand(256,256);
% J = MirrorEdges(I,2);
%
% See also padarray, ImagePad.

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

% Last revision on: 09.10.2012 16:15

%% Perform argument checks

narginchk(1, 2);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addOptional('size', [1 1], @(x) validateattributes( x, {'numeric'}, ...
    {'integer', 'nonnegative', 'vector'} ));

parser.parse(in, varargin{:});
opts = parser.Results;

%% Mirrors the boundary of an image in every direction by s pixel.

if isrow(opts.in) && (nargin == 1)
    out = padarray(opts.in, [0 1], 'symmetric');
elseif iscolumn(opts.in) && (nargin == 1)
    out = padarray(opts.in, [1 0], 'symmetric');
else
    out = padarray(opts.in, opts.size, 'symmetric');
end

end
