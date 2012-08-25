function y = FirmShrink( x, gam1, gam2 )
%% Performs firm shrinkage with thresholds gamma1 and gamma2.
%
% y = FirmShrink( x, gam1, gam2 )
%
% See also GarroteShrink, HardShrink, LinearShrink, SoftShrink

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

% Last revision: 25.08.2012 20:28

%% Check input parameters

narginchk(3, 3);
nargoutchk(0, 1);

%% Compute shrinkage.

y = x.*(abs(x)>gam2) + (sign(x).*(gam2*(abs(x)-gam1))/(gam2-gam1)) .* ...
    ( (abs(x)>=gam1).*(abs(x)<=gam2) );
end
