function out = ImageLapl( in, varargin )
%% Computes the Laplacian on a given 1D or 2D input signal.
%
% out = ImageLapl( in, ... )
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
% xSettings : either a structure or a cell array containing the optional
%             parameters that will be passed to ImageDxx to compute the 2nd x
%             derivative of the input image.
% ySettings : either a structure or a cell array containing the optional
%             parameters that will be passed to ImageDyy to compute the 2nd y
%             derivative of the input image.
% scheme    : if specified, it overrides xSettings and ySettings and applies
%             either the standard finite difference stencil for the Laplacian,
%             e.g. [0 1 0 ; 1 -4 1 ; 0 1 0] or it's rotationnally invariant
%             alternative 1/6*[1 4 1 ; 4 -20 4 ; 1 4 1]. The possible values for
%             this parameter are 'standard' (former scheme) or 'rotinv' (latter
%             scheme). (default = '')
% boundary  : if the parameter scheme has been specified, this structure will be
%             passed to the method AddBoundaryData to specify the handling of
%             the boundaries. The default will be to apply Neumann boundary
%             conditions by mirroring the data along the boundaries, e.g.
%             boundary = struct(type,'neumann'). Any parameter which would be
%             valid for the AddBoundaryData method can also be set here.
% gridSize  : a 2d vector specifying the grid size in x-direction (rows) and
%             y-direction (columns). Note that this parameter is only considered
%             when the scheme is not ''. If the scheme is not set, than the grid
%             size can be set using the settings for ImageDxx and ImageDyy.
%             (default = [1 1]).
% dim1      : boolean parameter that specifies whether a row or column signal
%             should be treated like a true 1D signal or whether it should be
%             considered like 2D signal with a singleton dimension. If true, it
%             is treated like a 1D signal. Note, that in that case, only the
%             standard scheme may be used. Also, if false and the signal is a
%             row or column vector and if the boundary struct has no field
%             'size', it will be set to [1 1] to enforce a 2D handling of the
%             underlying data. If the field is set, the users choice will be
%             repected. (default = true).
%
% Output parameters:
%
% out : an array with the same size as the input containing the laplacian at
%       each point.
%
% Description:
%
% Computes the Laplacian of an input signal using a finite difference scheme.
%
% Example:
%
% I = rand(512,256)
% xSettings.scheme = 'scharr';
% ySettings = { 'scheme', 'backward', 'gridSize', [1.5 1.5] };
% ImageLapl(I, xSettings, ySettings)
%
% See also ImageDxx, ImageDyy, convn, conv2, conv

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

% Last revision on: 21.10.2012 21:15

%% Check Input and Output Arguments

narginchk(1, 13);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'2d', 'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addParamValue('xSettings', struct([]), @(x) isstruct(x)||iscell(x) );
parser.addParamValue('ySettings', struct([]), @(x) isstruct(x)||iscell(x) );
parser.addParamValue('scheme', '', ...
    @(x) any(strcmpi(x,{'', 'standard','rotinv'})));
parser.addParamValue('boundary', struct('type','neumann'), @(x) isstruct(x));
parser.addParamValue('gridSize', [1 1], @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'vector', 'numel', 2, 'nonempty', 'nonsparse', ...
    'nonnan', 'finite', 'nonzero'}, mfilename, 'gridSize'));
parser.addParamValue('dim1', true, @(x) islogical(x)&&isscalar(x) );

parser.parse(in,varargin{:});
opts = parser.Results;

%% Algorithm

% Values in [0,1] yield discretisations for the Laplacian.
% a = 0   : standard discretisation.
% a = 1/3 : discretisation with rotationnally invariant leading error term.
filter = @(a) [ a/2 1-a a/2 ; 1-a 2*a-4 1-a ; a/2 1-a a/2 ]/prod(opts.gridSize);

if strcmpi(opts.scheme,'')
    out = ImageDxx(opts.in, opts.xSettings) + ImageDyy(opts.in, opts.ySettings);
elseif strcmpi(opts.scheme, 'standard')
    if opts.dim1 && isrow(opts.in)
        out = convn( AddBoundaryData(opts.in, opts.boundary), ...
            [1 -2 1]/opts.gridSize(1)^2, 'valid' );
    elseif opts.dim1 && iscolumn(opts.in)
        out = convn( AddBoundaryData(opts.in, opts.boundary), ...
            [1; -2; 1]/opts.gridSize(2)^2, 'valid' );
    else
        if ~isfield(opts.boundary,'size')
            opts.boundary.size = [1 1];
        end
        out = convn( AddBoundaryData(opts.in, opts.boundary), ...
            filter(0), 'valid' );
    end
else
    if opts.dim1 && isrow(opts.in)
        out = convn( AddBoundaryData(opts.in, opts.boundary), ...
            [1 -2 1]/opts.gridSize(1)^2, 'valid' );
    elseif opts.dim1 && iscolumn(opts.in)
        out = convn( AddBoundaryData(opts.in, opts.boundary), ...
            [1; -2; 1]/opts.gridSize(2)^2, 'valid' );
    else
        if ~isfield(opts.boundary,'size')
            opts.boundary.size = [1 1];
        end
        out = convn( AddBoundaryData(opts.in, opts.boundary), ...
            filter(1.0/3.0), 'valid' );
    end
end

