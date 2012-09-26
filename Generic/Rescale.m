function out = Rescale(in,outmin,outmax,gamma)
%% Perform linear rescale with gamma correction.
%
% out = Rescale(in,outmin,outmax,gamma)
%
% Input parameters (required):
%
% in     : input data.
% outmin : new minimum of output.
% outmax : new maximum of output.
%
% Input parameters (optional):
%
% gamma : optional gamma correction parameter. 
%
% Output parameters:
%
% out : rescaled input data.
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

% Last revision: 26.08.2012 21:16

%% Check input parameters

narginchk(3, 4);
nargoutchk(0, 1);

inmin = min(in(:));
inmax = max(in(:));
a = (outmax - outmin)./(inmax-inmin);
b = (inmax.*outmin-inmin.*outmax)./(inmax-inmin);
if nargin == 3
    out = (a.*in+b);
else
    out = (a.*in+b).^gamma;
end
end
