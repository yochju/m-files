function [out map] = ImageQuantize( in, q )
%% Short description.
%
% out = ImageQuantize( in )
%
% Input parameters (required):
%
%
%
% Input parameters (optional):
%
%
%
% Output parameters:
%
%
%
% Description:
%
%
%
% Example:
%
%
%
% See also

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

% Last revision on: 24.05.2012 17:25

%% Check Input and Output Arguments

%% Algorithm

I = double(in);

minI = min(I(:));
maxI = max(I(:));

if q > length(unique(round(in)))
    
    out = round(in);
    map = sort(unique(round(in)));
    
else
    
    temp = unique(in);
    map = FindBestPosition(temp,linspace(minI,maxI,q))-1;
    out = FindBestPosition(linspace(minI,maxI,q),in);
    
end
end
