function out = ImageGradMag( in, varargin )
%% Computes the gradient magnitude of an input image.
%
% out = ImageGradMag( in, varargin )
%
% Input parameters (required):
%
% in : input image (matrix)
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
% xSettings : either a structure or a cell array containing the optional
%             parameters that will be passed to ImageDx to compute the x
%             derivative of the input image.
% ySettings : either a structure or a cell array containing the optional
%             parameters that will be passed to ImageDx to compute the x
%             derivative of the input image.
% norm      : norm to be used for computation (default = 2).
%
% Output parameters:
%
% out : signal of same size as input containg the gradient magnitude.
%
% Description:
%
% Computes the gradient magnitude in the p-Norm pointwise.
%
% Example:
%
% I = rand(128,512);
% ImageGrad(I);
%
% See also ImageGrad

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

% Last revision on: 02.05.2012 17:40

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

parser.addParamValue('norm', 2, @(x) validateattributes(x, ...
    {'numeric'}, {'nonnegative'}));

parser.parse(in,varargin{:});
opts = parser.Results;

%% Algorithm

grad = ImageGrad(in,varargin{:});
p = opts.norm;
out = (abs(grad(:,:,1)).^p + abs(grad(:,:,2)).^p).^(1/p);

end
