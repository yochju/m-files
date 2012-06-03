function out = ImageToVector( in, varargin )
%% Reorders the pixels from an image into a vector.
%
% out = ImageToVector( in )
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
% ordering : how the pixels are going to be reordered. Possible options are:
%            'row-wise' and 'column-wise' (default)
% size     : a 2d vector containing the original image size. This option is only
%            necessary when the data should be transformed back into an 2d
%            array.
%
% Output parameters:
%
% out : reshaped version of the input image.
%
% Description:
%
% Reshapes the input matrix into a vector, either by labeling the entries
% row-wise or column-wise. The default is column-wise labeling. If the input is
% a vector, then the algorithm will try to reshape the input back into an image.
% In that case the size of the original image must be specified. If the ordering
% is not specified, it will be assumed to be the default column-wise ordering.
%
% Example:
%
% I = rand(256,256);
% ImageToVector(I,'ordering','column-wise');
%
% See also reshape, mat2cell

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

% Last revision on: 11.05.2012 10:25

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

parser.addParamValue('ordering', 'column-wise', @(x) strcmpi(x, ...
    validatestring( x, {'row-wise', 'column-wise'}, mfilename, 'ordering') ) );

parser.addParamValue('size', [0 0], @(x) validateattributes( x, ...
    {'numeric'}, {'finite', 'nonnegative', 'real' 'nonempty', ...
    'size', [1  2]}, mfilename, 'size'));

parser.parse(in,varargin{:});
opts = parser.Results;

%% Algorithm

if iscolumn(in)
    assert( ~isequal(opts.size, [0 0]), ...
        ['ImageAnalysis:' mfilename ':BadInput'], ...
        'Backtransformation requires that the image size is specified.');
    switch opts.ordering
        case 'row-wise'
            out = reshape(in, opts.size(2), opts.size(1))';
        case 'column-wise'
            out = reshape(in, opts.size(1), opts.size(2));
    end
else
    switch opts.ordering
        case 'row-wise'
            temp = in';
            out = temp(:);
        case 'column-wise'
            out = in(:);
    end
end

end