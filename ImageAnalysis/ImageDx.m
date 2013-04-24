function out = ImageDx(in, varargin)
%% Computes the image derivative in x-direction.
%
% out = ImageDx(in, varargin)
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
% scheme   : the finite difference scheme to be used. Supported values are
%            'forward' = forward finite differences (default).
%            'backward' = backward finite differences.
%            'central' = central finite differences.
%            'central-4' = central 4th order scheme.
%            'sobel' = sobel operator.
%            'scharr' = scharr operator.
%            'user-specified' = stencil specified by the user. The stencil must
%            have odd dimensions > 1 in each direction.
% stencil  : stencil used in conjuction with the 'user-specified' scheme.
% gridSize : grid size (for x and y direction).
% boundary : how the boundary are to be treated. Possible values are
%            'neumann' = mirroring the boundary. (default)
%            'dirichlet' = specifying certain values at the boundary. In that
%            case the option bData must also be specified.
% bData    : structure containing the data to be specified at the border. Will
%            be passed "as is" to ImagePad. The size of the data should be in
%            accordance with the filter size to be applied. There is no checking
%            for dimensions. Especially, the output cout be larger than the
%            input signal.
%
% Output parameters
%
% out : Image x-derivative of input image in.
%
% Description:
%
% The function computes the derivative in x-direction of an image (the origin
% being in the top left corner) using a finite difference scheme.
%
% Example:
%
% I = rand(256,256);
% options.scheme = 'scharr';
% options.gridSize = [0.5 0.5];
% Ix = ImageDy(I,options);
%
% which is equivalent to:
%
% Ix = ImageDx(I,'scheme','scharr','gridSize',[0.5 0.5]);
%
% See also ImageDxx, ImageDy, ImageDyy, ImageDxy, filter2, imfilter.

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

% Last revision on: 24.04.2013 09:55

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

parser.addParamValue('scheme', 'forward', @(x) strcmpi(x, validatestring( x, ...
    {'forward', 'backward', 'central', 'central-4', ...
    'sobel', 'scharr', 'user-specified'}, ...
    mfilename, 'scheme') ) );

parser.addParamValue('gridSize', [1.0 1.0] , @(x) validateattributes( x, ...
    {'numeric'}, {'positive', 'vector'}, mfilename, 'gridSize') );

parser.addParamValue('stencil', [], @(x) validateattributes( x, ...
    {'numeric'}, {'2d', 'finite', 'nonnan'}, mfilename, 'stencil') );

parser.addParamValue('boundary', 'neumann', @(x) strcmpi(x, ...
    validatestring( x, {'neumann', 'dirichlet'}, mfilename, 'boundary') ) );

parser.addParamValue('bData', struct([]), @(x) validateattributes( x, ...
    {'struct'}, {}, mfilename, 'bData') );

try
    parser.parse(in,varargin{:})
catch err
    % If an empty structure is passed as option, redo the parsing with some
    % dummy data that doesn't affect the result.
    if strcmp(err.identifier,'MATLAB:InputParser:StructureMustBeScalar')
        parser.parse(in,struct('dummy',-1));
    else
        rethrow(err);
    end
end

opts = parser.Results;

assert( length(opts.gridSize) == 2, ...
    ['ImageAnalysis:' mfilename ':BadInput'], ...
    'Grid size must be an array with 2 elements.' );

%% Compute the x-derivative.

hx = opts.gridSize(1);
% hy = opts.gridSize(2);

% Pad the image accordingly.
if strcmpi(opts.boundary,'neumann')
    
    if strcmpi(opts.scheme,'user-specified')
        
        assert( ~isempty(opts.stencil), ...
            ['ImageAnalysis:' mfilename ':BadInput'], ...
            'User-specified schemes require non-empty stencils.');
        
        stencilSize = size(opts.stencil);
        
        assert(all( mod(stencilSize,2) ), ...
            ['ImageAnalysis:' mfilename ':BadInput'], ...
            'User-specified stencils must have odd dimensions.');
        
        out = MirrorEdges(in, max((stencilSize-1)/2,1));
        
    else
        
        out = MirrorEdges(in,[1 1]);
        
    end
    
else
    
    assert( ~isempty(opts.bData), ...
        ['ImageAnalysis:' mfilename ':BadInput'], ...
        'Boundary data must be specified with dirichlet conditions.');
    
    if strcmpi(opts.scheme,'user-specified')
        
        assert( ~isempty(opts.stencil), ...
            ['ImageAnalysis:' mfilename ':BadInput'], ...
            'User-specified schemes require non-empty stencils.');
        
        stencilSize = size(opts.stencil);
        
        assert(all( mod(stencilSize,2) ), ...
            ['ImageAnalysis:' mfilename ':BadInput'], ...
            'User-specified stencils must have odd dimensions.');
        
    end
    
    out = ImagePad(in, opts.bData);
    
end

% Ues a convolution to compute the image derivatives.
switch opts.scheme
    
    case 'forward'
        out = filter2( [0 0 0 ; 0 -1 1 ; 0 0 0]/hx, ...
            out, 'valid' );
        
    case 'backward'
        out = filter2( [0 0 0 ; -1 1 0 ; 0 0 0]/hx, ...
            out, 'valid' );
        
    case 'central'
        out = filter2( [0 0 0 ; -1 0 1 ; 0 0 0]/(2*hx), ...
            out, 'valid' );
        
    case 'central-4'
        out = filter2( [0 0 0 0 0 ; 1 -8 0 8 -1 ; 0 0 0 0 0]/(12*hx), ...
            out, 'valid' );
        
    case 'sobel'
        out = filter2( [-1 0 1 ; -2 0 2 ; -1 0 1]/(8*hx), ...
            out, 'valid' );
        
    case 'scharr'
        out = filter2( [-3 0 3 ; -10 0 10 ; -3 0 3]/(32*hx), ...
            out, 'valid' );
        
    case 'user-specified'
        out = filter2( opts.stencil, ...
            out, 'valid' );
end

end
