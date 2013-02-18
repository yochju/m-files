function [out] = Im2ColSignalMask(SigSize, WinSize)
%% Generate a Mask of image pixels for the im2col function.
%
% [out] = Im2ColSignalMask(SigSize, WinSize)
%
% Input parameters (required):
%
% SigSize : Size of the image. Vector of form [nr nc].
% WinSize : Size of the sliding window. Vector of form [nr nc]. Window must have
%           odd size in every direction.
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
% out : Mask compute with im2col where nan indicate pixels that do not belong to
%       the image but were added due to padding.
%
% Output parameters (optional):
%
% -
%
% Description:
%
% -
%
% Example:
%
% -
%
% See also im2col, nlfilter, colfilt, col2im, blockproc

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

% Last revision on: 17.02.2013 11:45

%% Notes

%% Parse input and output.

narginchk(2,2);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('SigSize', @(x) validateattributes( x, {'numeric'}, ...
    {'vector', 'numel', 2, 'integer', 'positive'}, mfilename, 'SigSize', 1) );

parser.addRequired('WinSize', @(x) validateattributes( x, {'numeric'}, ...
    {'vector', 'numel', 2, 'integer', 'positive', 'odd', '>', 1}, ...
    mfilename, 'WinSize', 1) );

parser.parse(SigSize,WinSize);

%% Run code.

out = im2col(                                          ...
    ImagePad( ones(SigSize),                           ...
    'left',   nan(SigSize(1), (WinSize(2)-1)/2),       ...
    'right',  nan(SigSize(1), (WinSize(2)-1)/2),       ...
    'top',    nan((WinSize(1)-1)/2, SigSize(2)),       ...
    'bottom', nan((WinSize(1)-1)/2, SigSize(2)),       ...
    'uleft',  nan((WinSize(1)-1)/2,(WinSize(2)-1)/2),  ...
    'uright', nan((WinSize(1)-1)/2,(WinSize(2)-1)/2),  ...
    'bleft',  nan((WinSize(1)-1)/2,(WinSize(2)-1)/2),  ...
    'bright', nan((WinSize(1)-1)/2,(WinSize(2)-1)/2)), ...
    WinSize, 'sliding');

end
