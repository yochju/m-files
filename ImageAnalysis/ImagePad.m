function out = ImagePad( in, varargin )
%% Short description.
%
% out = ImagePad( in )
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
% left   : values with which the input signal should be padded at the left side.
%          Must be a n x m matrix where n is the number of rows of the input
%          image.
% right  : values with which the input signal should be padded at the right
%          side. Must be a n x m matrix where n is the number of rows of the
%          input image.
% top    : values with which the input signal should be padded at the top. Must
%          be a n x m matrix where m is the number of coloumns of the input
%          image.
% bottom : values with which the input signal should be padded at the top. Must
%          be a n x m matrix where m is the number of coloumns of the input
%          image
% uleft  : values to be placed in the upper left corner of the padded domain.
%          (default zero matrix of corresponding size)
% uright : values to be placed in the upper right corner of the padded domain.
%          (default zero matrix of corresponding size)
% bleft  : values to be placed in the lower left corner of the padded domain.
%          (default zero matrix of corresponding size)
% bright : values to be placed in the lower right corner of the padded domain.
%          (default zero matrix of corresponding size)
%
% Output parameters:
%
% out : array containing the original image with padded boundaries.
%
% Description:
%
%
%
% Example:
%
%
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

% Last revision on: 21.10.2012 20:00

%% Notes

% Has been implemented in @Image.

%% Check Input and Output Arguments

% asserts that there's at least 1 input parameter.
narginchk(1, 17);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );
   
parser.addParamValue('left', [] , @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'nonempty'}, mfilename, 'left') );
parser.addParamValue('right', [] , @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'nonempty'}, mfilename, 'right') );
parser.addParamValue('top', [] , @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'nonempty'}, mfilename, 'top') );
parser.addParamValue('bottom', [] , @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'nonempty'}, mfilename, 'bottom') );

parser.addParamValue('uleft', [] , @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'nonempty'}, mfilename, 'bottom') );
parser.addParamValue('bleft', [] , @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'nonempty'}, mfilename, 'bottom') );
parser.addParamValue('uright', [] , @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'nonempty'}, mfilename, 'bottom') );
parser.addParamValue('bright', [] , @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'nonempty'}, mfilename, 'bottom') );

parser.parse(in,varargin{:});
opts = parser.Results;

% Check that arrays for padding have the correct size and set corners to 0 if
% they weren't specified.

ExcM = ExceptionMessage('BadDim');

ExcM.message = 'Left padding has wrong dimension.';
if ~isempty(opts.left)
    assert( size(opts.left,1) == size(in,1), ExcM.id, ExcM.message );
end

ExcM.message = 'Right padding has wrong dimension.';
if ~isempty(opts.right)
    assert( size(opts.right,1) == size(in,1), ExcM.id, ExcM.message );
end

ExcM.message = 'Top padding has wrong dimension.';
if ~isempty(opts.top)
    assert( size(opts.top,2) == size(in,2), ExcM.id, ExcM.message );
end

ExcM.message = 'Bottom padding has wrong dimension.';
if ~isempty(opts.bottom)
    assert( size(opts.bottom,2) == size(in,2), ExcM.id, ExcM.message );
end

ExcM.message = 'Top left padding has wrong dimension.';
if ~isempty(opts.uleft)
    assert( ...
        size(opts.uleft,1) == size(opts.top ,1) && ...
        size(opts.uleft,2) == size(opts.left,2) , ExcM.id, ExcM.message );
else
    opts.uleft = zeros( size(opts.top, 1), size(opts.left, 2) );
end

ExcM.message = 'Bottom left padding has wrong dimension.';
if ~isempty(opts.bleft)
    assert( ...
        size(opts.bleft,1) == size(opts.bottom ,1) && ...
        size(opts.bleft,2) == size(opts.left,2) , ExcM.id, ExcM.message );
else
    opts.bleft = zeros( size(opts.bottom, 1), size(opts.left, 2) );
end

ExcM.message = 'Top right padding has wrong dimension.';
if ~isempty(opts.uright)
    assert( ...
        size(opts.uright,1) == size(opts.top ,1) && ...
        size(opts.uright,2) == size(opts.right,2), ExcM.id, ExcM.message );
else
    opts.uright = zeros( size(opts.top ,1), size(opts.right,2) );
end

ExcM.message = 'Bottom right padding has wrong dimension.';
if ~isempty(opts.bright)
    assert( ...
        size(opts.bright,1) == size(opts.bottom ,1) && ...
        size(opts.bright,2) == size(opts.right,2) , ExcM.id, ExcM.message );
else
    opts.bright = zeros( size(opts.bottom, 1), size(opts.right, 2) );
end

%% Algorithm

out = [ ...
    opts.uleft opts.top    opts.uright ; ...
    opts.left  opts.in     opts.right  ; ...
    opts.bleft opts.bottom opts.bright ];

end
