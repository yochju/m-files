function out = MirrorEdges(in, varargin)
%% Mirrors image edges in each direction by s pixel.
%
% out = MirrorEdges(in)
%
% Input parameters (required):
%
% in : input image (matrix).
%
% Input parameters (optional):
%
% size : size of dummy boundaries (scalar, default = [1 1]).
%
% Output parameters
%
% out : image with mirrored edges.
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

% Last revision on: 07.05.2012 22:07

%% Perform argument checks

error(nargchk(1, 2, nargin));
error(nargoutchk(0, 1, nargout));

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

parser.parse(in,varargin{:});
opts = parser.Results;

%% Mirrors the boundary of an image in every direction by s pixel.
out = padarray(in, opts.size, 'symmetric');

end