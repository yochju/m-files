function [ c0 ] = GenerateMask( c , NumP, Max )
% Erstellt eine 1D Maske mit NumP Stützstellen. Ist c == r, so sind die
% Stützstellen zufällig Verteilt.

% [ c0 ] = GenerateMask( c , NumP, Max )
% Generates a Mask of NumP positions for knots for a vector of length Max.
%
% Usage: [ c0 ] = GenerateMask( c , NumP, Max )
% c    : the method to use. 'u' means uniform. 'r' random.
% NumP : Number of mask points.
% Max  : Maximal possible value a mask point should attain.
% c0   : the obtained mask.

% Copyright 2011,2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision: 05.09.2012 16:10

%% Check number of input and output arguments.

narginchk(3,3);
nargoutchk(0,1);

if strcmp('u',c)
    c0 = round(linspace(1,Max,NumP));
elseif strcmp('r',c)
    temp = randperm(Max-2) + 1;
    c0 = [ 1 sort(temp(1:(NumP-2))) Max ];
else
    warning('GenerateMask:argChk','Method for generating the mask not recognized.');
    c0 = round(linspace(1,Max,NumP));
end
end
