function out = ImageDeriv( in, varargin )
%% Computes image derivatives iteratively.
%
% out = Imagederiv( in, varargin )
%
% Input parameters (required):
%
% in : input image (matrix).
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% xDerivatives : a cell array containing structs that are passed to ImageDx. The
%                derivatives are applied iteratively.
% yDerivatives : a cell array containing structs that are passed to ImageDy. The
%                derivatives are applied iteratively.
%
% Output parameters:
%
% out : Image deirvative of the input image.
%
% Description:
%
% The function computes an arbitrary image derivative of a given input image.
% The derivatives are applied iteratively in the order they have been passed.
% First the x derivatives and then the y derivatives will be computed.
%
% Example:
%
% I = rand(128,192);
% dx1 = struct('scheme', 'central', 'gridSize', [0.5 0.5]);
% dy1 = struct('scheme', 'forward', 'gridSize', [0.5 0.5]);
% dy2 = struct('scheme', 'backward', 'gridSize', [0.5 0.5]);
% out = ImageDeriv(I,{dx1, dx1, dy1, dy1});
%
% See also ImageDx, ImageDy.

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

% Last revision on: 05.05.2012 17:13

%% Check Input and Output Arguments

% asserts that there's at least 1 input parameter.
error(nargchk(1, max(nargin,0), nargin));
error(nargoutchk(0, 1, nargout));

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );
   
parser.addParamValue('xDerivatives', struct([]) , ...
    @(x) validateattributes( x, {'cell'}, {'vector'}, ...
    mfilename, 'xDerivatives') );

parser.addParamValue('yDerivatives', struct([]) , ...
    @(x) validateattributes( x, {'cell'}, {'vector'}, ...
    mfilename, 'yDerivatives') );

parser.parse(in,varargin{:})
opts = parser.Results;

%% Algorithm

out = opts.in;

for i = 1:length(opts.xDerivatives)
    out = ImageDx(out, opts.xDerivatives{i});
end

for i = 1:length(opts.yDerivatives)
    out = ImageDy(out, opts.yDerivatives{i});
end

end