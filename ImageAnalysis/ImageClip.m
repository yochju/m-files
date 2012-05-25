function out = ImageClip( in , range , varargin )
%% Projects all the input values onto the range set.
%
% out = ImageClip( in , range , varargin )
%
% Input parameters (required):
%
% in    : input image (matrix).
% range : either a scalar or a vector (of length 2) indication one extrema or
%         the whole range in which the input values should be projected.
%
% Input parameters (optional):
%
% range2 : if the parameter range is a scalar, this parameter indicates the
%          second extrema of the range.
%
% Output parameters:
%
% out : a signal of the same size as the input signal where all the values
%       outside of the indicated range are projected onto the closest range
%       bounds.
%
% Description:
%
% Projects values outside of the indicated range onto the interval indicating
% the valid values. The bounds can be indicated in any order.
%
% Example:
%
% ImageClip([1 2 3 4], 2, 3)
% ImageClip([1 2 3 4], 3, 2)
% ImageClip([1 2 3 4], [2 3])
% ImageClip([1 2 3 4], [3 2])
%
% all yield the result [2 2 3 3].
%
% See also

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

% Last revision on: 25.05.2012 13:57

%% Check Input and Output Arguments

error(nargchk(2, 3, nargin));
error(nargoutchk(0, 1, nargout));

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addRequired('range', @(x) validateattributes( x, ...
    {'numeric'}, {'>', 0, 'nonnan', 'real', 'vector'}, ...
    mfilename, 'range') );

parser.addOptional('range2', inf, @(x) validateattributes( x, ...
    {'numeric'}, {'>', 0, 'nonnan', 'real', 'scalar'}, ...
    mfilename, 'range2') );

parser.parse(in,range,varargin{:});
opts = parser.Results;

if isscalar(opts.range)
    rmin = min([opts.range opts.range2]);
    rmax = max([opts.range opts.range2]);
else
    if length(opts.range) ~= 2
        warning(['ImageAnalysis:' mfilename ':BadInput'], ...
            'Range contains more than two values.');
    end
    rmin = min(opts.range(:));
    rmax = max(opts.range(:));
end

%% Algorithm

out = opts.in;
out(out>rmax) = rmax;
out(out<rmin) = rmin;

end