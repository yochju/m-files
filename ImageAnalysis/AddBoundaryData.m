function out = AddBoundaryData(in, varargin)
%% Extends input edges in each direction with specific boundary data.
%
% out = AddBoundaryData(in, ...)
%
% Input parameters (required):
%
% in : input signal (array).
%
% Input parameters (optional):
%
% Optional parameters are either struct with the following fields and
% corresponding values or option/value pairs, where the option is specified as a
% string.
%
% type : how the signal should be extended. Valid choices are 'dirichlet'
%        (padding with 0s) or 'neumann' (mirroring edges). (default = 'neumann')
% size : size of dummy boundaries (default = [1 1] for 2d, [0 1] for
%        row- and [1 0] for column arrays as input.). Can be any input that
%        would also be valid for the padarray method.
% data : if type was set to 'dirichlet' then the specified data will be used
%        instead of the default value 0 for the boundary values. data should be
%        a struct (which will be passed as-is to ImagePad). Note that if this
%        parameter is set, then any specification for 'size' will be ignored and
%        the size will be computed from the data. (default struct([]))
%
% Output parameters
%
% out : image with mirrored edges.
%
% Description
%
% Adds a dummy boundary around an input signal. If input is a 1D signal (e.g. a
% row or column vector, then, the mirroring ins applied only on the endpoints if
% the optional parameter for the size is omitted. For 2D signals, the default
% behavior is to apply neumann boundary conditions along every edge.
%
% Example:
% I = rand(256,256);
% J = AddBoundaryData(I,2);
%
% See also padarray, ImagePad.

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

% Last revision on: 21.10.2012 20:30

%% Perform argument checks

narginchk(1, 7);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', @(x) validateattributes( x, {'numeric'}, ...
    {'finite', 'nonempty', 'nonnan'}, ...
    mfilename, 'in', 1) );

parser.addParamValue('type', 'neumann', @(x) strcmpi(x,validatestring(x, ...
    {'neumann', 'dirichlet'}, mfilename, 'type')));

parser.addParamValue('size', inf, ...
    @(x) validateattributes( x, {'numeric'}, ...
    {'integer', 'nonnan', 'finite', 'nonnegative', 'vector'} ));

parser.addParamValue('data', struct([]), @(x) isstruct(x));

parser.parse(in, varargin{:});
opts = parser.Results;

% NOTE: This method renders MirrorEdges.m obsolete.
% TODO: Add the ImagePad functionality. opts.padData (keep ImagePad).

% If size has not been specified, check if input is 1D or not.
% If it is 1D, treat it as such for the padding.
if isequal(opts.size, inf)
    if isrow(opts.in)
        opts.size = [0 1];
    elseif iscolumn(opts.in)
        opts.size = 1;
    else
        % This extends the boundary along every dimension by 1. Note that this
        % formulation is dimension agnostic and works for any size.
        opts.size = ones(1,numel(size(opts.in)));
    end
end

switch lower(opts.type)
    case 'dirichlet'
        if isempty(opts.data)
            out = padarray(opts.in, opts.size);
        else
            out = ImagePad(opts.in, opts.data);
        end
    case 'neumann'
        out = padarray(opts.in, opts.size, 'symmetric');
end

end
