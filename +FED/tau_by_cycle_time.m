function out = tau_by_cycle_time(t, tau_max, reordering)

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

% Last revision on: 31.10.2012 9:00

%n = fix(ceil(sqrt(3.0*t/tau_max+0.25)-0.5-1.0e-8)+0.5);

% This is not exactly the same as in the code, but according to the theory it
% should be correct. The difference with the original code lies in those numbers
% where the solution is exact (although it's not systematic).
n = ceil(sqrt(3*t./tau_max + 0.25)-0.5);
scale = 3.0*t/(tau_max*(n*(n+1)));
out = tau_internal(n, scale, tau_max, reordering);
end
%  [ (0.0:0.1:8.4) ; round(sqrt(3.0*(0.0:0.1:8.4)/tau_max+0.25)) ]
