function out = MorphologicalSelfDualTopHat(in, mask1, varargin)
%% Apply a Morphological White Top Hat.
%
% out = MorphologicalSelfDualTopHat(in, mask1, mask2, mask3, mask4)
%
% Input parameters (required):
%
% in    : input image. (array)
% mask1 : 2D array with odd number of rows and columns. Center will be the mid
%         pixel along every direction. Entries serve as weights. NaNs mark
%         pixels to be ignored.
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
% The number of optional parameters is always at most three. If a function takes
% an optional parameter, it does not take any other parameters. The parameters
% must be passed in the documented order. The parser is unable to distinguish
% them!
%
% mask2 : 2D array with odd number of rows and columns. Center will be the mid
%         pixel along every direction. Entries serve as weights. NaNs mark
%         pixels to be ignored. This will be the first mask for the
%         morphological BlackTopHat. (default = mask1)
%
% mask3 : 2D array with odd number of rows and columns. Center will be the mid
%         pixel along every direction. Entries serve as weights. NaNs mark
%         pixels to be ignored. This will be the second mask for the
%         morphological WhiteTopHat. (default = mask1)
%
% mask4 : 2D array with odd number of rows and columns. Center will be the mid
%         pixel along every direction. Entries serve as weights. NaNs mark
%         pixels to be ignored. This will be the second mask for the
%         morphological BlackTopHat. (default = mask1 if mask2 is not specified
%         and mask2 if specified.)
%
% Output parameters:
%
% out : Resulting image.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Applies a Morphological White Top Hat on a given image. The mask is cropped at
% the image boundaries. No padding at all is being performed.
%
% Example:
%
% mask = [nan 1 1 ; 1 4 nan ; 0 0 2 ];
% I = double(rand(16,16) > 0.2);
% MorphologicalSelfDualTopHat(I,mask);
%
% See also MorphologicalBlackTopHat, MorphologicalWhiteTopHat

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

% Last revision on: 01.03.2013 08:06

%% Notes

%% Parse input and output.

narginchk(2,5);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'nonsparse', 'nonempty'}, mfilename, 'in', 1) );

parser.addRequired('mask1', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'nonsparse', 'nonempty'}, mfilename, 'mask1', 2) );

parser.addOptional('mask2', mask1, @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'nonsparse', 'nonempty'}, mfilename, 'mask2', 3) );

parser.addOptional('mask3', mask1, @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'nonsparse', 'nonempty'}, mfilename, 'mask3', 4) );

% If mask2 is specified, mask4 should default to mask2, otherwise to mask1.
if (nargin < 3)
    parser.addOptional('mask4', mask1, @(x) validateattributes( x, ...
        {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, mfilename, 'mask4', 5) );
else
    parser.addOptional('mask4', varargin{1}, @(x) validateattributes( x, ...
        {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, mfilename, 'mask4', 5) );
end
    
parser.parse(in, mask1, varargin{:});
opts = parser.Results;

%% Run code.

out = MorphologicalWhiteTopHat(in, mask1, opts.mask3) + ...
    MorphologicalBlackTopHat(in, opts.mask2, opts.mask4);

end
