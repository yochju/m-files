function out = ImageSmooth( in, varargin )
%% Smoothes a given input image.
%
% out = ImageSmooth( in, varargin )
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
% filter        : the filter to be used for the smoothing. Possible values are
%                 'average', 'disk' and 'gaussian' (default).
% averageSize   : size of the averaging filter. (default = [3 3]).
% diskSize      : radius of the disk filter. (default = 5).
% gaussianSize  : size of the gaussian filter. (default = [3 3]).
% gaussianSigma : standard deviation of the gaussian. (default = 0.5).
%
% Output parameters:
%
% out : smoothed version of the input image.
%
% Description:
%
% Applies a smoothing algorithm onto the input image. The function uses the
% builtin filters offered by fspecial.
%
% Example:
%
% I = rand(256,256);
% ImageSmooth(I);
%
% See also fspecial, imfilter

% Copyright 2012, 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 24.04.2013 09:45

%% Check Input and Output Arguments

% asserts that there's at least 1 input parameter.
narginchk(1, max(nargin,0));
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addParamValue('filter', 'gaussian', @(x) strcmpi(x, validatestring( x, ...
    {'average', 'disk', 'gaussian'}, mfilename, 'method') ) );

parser.addParamValue('averageSize', [3 3], @(x) validateattributes( x, ...
    {'numeric'}, {'finite', 'nonnegative', 'real' 'nonempty', 'vector'}, ...
    mfilename, 'scaling'));

parser.addParamValue('diskSize', 5, @(x) validateattributes( x, ...
    {'numeric'}, {'finite', 'nonnegative', 'real' 'nonempty', 'scalar'}, ...
    mfilename, 'scaling'));

parser.addParamValue('gaussianSize', [3 3], @(x) validateattributes( x, ...
    {'numeric'}, {'finite', 'nonnegative', 'real' 'nonempty', 'vector'}, ...
    mfilename, 'scaling'));

parser.addParamValue('gaussianSigma', 0.5, @(x) validateattributes( x, ...
    {'numeric'}, {'positive', 'nonempty', 'integer', 'scalar'}, ...
    mfilename, 'maxScales'));

parser.parse(in,varargin{:});
opts = parser.Results;

%% Algorithm

switch opts.filter
    case 'average'
        h = fspecial(opts.filter, opts.averageSize);
    case 'disk'
        h = fspecial(opts.filter, opts.diskSize);
    case 'gaussian'
        h = fspecial(opts.filter, opts.gaussianSize, opts.gaussianSigma);
end

out = imfilter(in,h,'symmetric','same');

end
