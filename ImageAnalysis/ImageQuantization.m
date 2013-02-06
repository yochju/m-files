function out = ImageQuantization(in, num)
%% Changes the number of colors in the input image.
%
% out = ImageQuantization(in, num)
%
% Input parameters (required):
%
% in  : Input image. (array)
% num : Number of desired colors in the output image.
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% -
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% -
%
% Output parameters:
%
% out : Quantized version of the input data.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Uses nearest neighbour interpolation on [min(in(:));max(in(:))] to requantize
% the data in such a way that at most num different colors are used. If num is
% larger than the current number of colours, the image remains unchanged. If num
% is 1, all pixels will have the average value of the input data.
%
% Example:
%
% I = rand([10,10]);
% J = ImageQuantization(I,5);
%
% See also interp1, FindBestPosition

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 06.02.2013 14:38

%% Notes

%% Parse input and output.

narginchk(2,2);
nargoutchk(0,2);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan', 'nonsparse'}, ...
    mfilename, 'in', 1) );

parser.addRequired('num', @(x) validateattributes( x, {'numeric'}, ...
    {'scalar', 'finite', 'nonempty', 'nonnan', '>=', 1}, ...
    mfilename, 'num', 2) );

parser.parse(in, num);

%% Run code.

Imin = min(in(:));
Imax = max(in(:));

if num == 1
    out = mean(in(:))*ones(size(in));
else
    quantization = linspace(Imin,Imax,num);
    out = quantization(FindBestPosition(quantization,in));
end

end
