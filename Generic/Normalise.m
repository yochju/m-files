function out = Normalise(in,gamma)
%% Perform normalisation with optional gamma correction.
%
% out = Normalise(in,gamma)
%
% Input parameters (required):
%
% in     : input data.
%
% Input parameters (optional):
%
% gamma : optional gamma correction parameter. 
%
% Output parameters:
%
% out : normalised input data.
%
% See also imadjust

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

% Last revision: 26.08.2012 21:20

%% Check input parameters

narginchk(1, 2);
nargoutchk(0, 1);

out = Rescale(in,0,1,gamma);
end
