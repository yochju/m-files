function out = ImageLapl( in, varargin )
%% Computes the Laplacian on an image.
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
%             scheme).
% boundary :  if the parameter scheme has been specified, this structure will be
%             passed to the method MirrorEdges to specify the mirroring of the
%             boundaries. The default will be to apply Neumann boundary
%             conditions by mirroring the data along the boundaries, e.g.
%             boundary = struct('size',[1 1]). Note that this also treats 1D
%             input signals as 2D signals with a singleton dimension.
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
% See also ImageDxx, ImageDyy

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

% Last revision on: 15.10.2012 21:30

%% Check Input and Output Arguments

narginchk(1, 9);
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
parser.addParamValue('scheme', '', @(x) any(strcmpi(x,{'standard','rotinv'})));
parser.addParamValue('boundary', struct('size',[1 1]), @(x) isstruct(x));

parser.parse(in,varargin{:});
opts = parser.Results;

%% Algorithm

% Values in [0,1] yield discretisations for the Laplacian.
% a = 0   : standard discretisation.
% a = 1/3 : discretisation with rotationnally invariant leading error term.
filter = @(a) [ a/2 1-a a/2 ; 1-a 2*a-4 1-a ; a/2 1-a a/2 ];

if strcmpi(opts.scheme,'')
    out = ImageDxx(opts.in, opts.xSettings) + ImageDyy(opts.in, opts.ySettings);
elseif strcmpi(opts.scheme, 'standard')
    out = convn( MirrorEdges(opts.in, opts.boundary), filter(0), 'valid' );
else
    out = convn( MirrorEdges(opts.in, opts.boundary), filter(1/3), 'valid' );
end

