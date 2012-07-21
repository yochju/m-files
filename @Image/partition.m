function out = partition( obj, blockSize, varargin )
%% Partitions the input image into blocks and stores them in a cell array.
%
% out = partition( obj, blockSize, varargin )
%
% Input parameters (required):
%
% in        : input image.
% blockSize : scalar stating number of rows for each block or vector of length 2
%             specifying the size of each block.
%
% Input parameters (optional):
%
% blockCols : if blockSize is scalar, then a second  scalar parameter specifying
%             the number of columns for each block is required. 
%
% Output parameters:
%
% out : cell array containing the individual blocks.
%
% Description:
%
% This function takes an image and partitions it into blocks if identical
%
% Example:
%
%
%
% See also mat2cell, cell2mat, num2cell

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 21.07.2012 21:30

%% Check Input and Output Arguments

error(nargchk(2, 3, nargin));
error(nargoutchk(0, 1, nargout));

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('obj', @(x) isa(x,'Image') );

parser.addRequired('blockSize', @(x) validateattributes( x, ...
    {'numeric'}, {'>', 0, 'finite', 'integer', 'nonnan', 'real', 'vector'}, ...
    mfilename, 'blockSize') );

parser.addOptional('blockCols', -1, @(x) validateattributes( x, ...
    {'numeric'}, {'>', 0, 'finite', 'integer', 'nonnan', 'real', 'scalar'}, ...
    mfilename, 'blockCols') );

parser.parse(obj,blockSize,varargin{:});
opts = parser.Results;

if isscalar(opts.blockSize)
    ExcM = ExceptionMessage('Missing', ...
        'Number of columns for each block has not been specified.');
    assert( opts.blockCols ~= -1, ExcM.id, ExcM.message );
    br = opts.blockSize;
    bc = opts.blockCols;    
else
    ExcM = ExceptionMessage('Input', ...
        'blockSize must be a vector of length 2 or a scalar.');
    assert( length(opts.blockSize) == 2, ExcM.id, ExcM.message );
    br = opts.blockSize(1);
    bc = opts.blockSize(2);
end

[nr nc] = size(in);

ExcM = ExceptionMessage('Input');
ExcM.message = sprintf( ...
    'Cannot divide %d rows into blocks of size %d', nr, br );
assert( mod(nr,br) == 0, ExcM.id, ExcM.message);

ExcM.message = sprintf( ...
    'Cannot divide %d columns into blocks of size %d', nc, bc );
assert( mod(nc,bc) == 0, ExcM.id, ExcM.message );

%% Algorithm

out = mat2cell( in , br*ones(1,nr/br) , bc*ones(1,nc/bc) );

end