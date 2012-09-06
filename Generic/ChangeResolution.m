function out = ChangeResolution(in,factor)
    %Resamples a 1D Signal by a given factor.
    
    % Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
    %
    % This program is free software; you can redistribute it and/or modify it
    % under the terms of the GNU General Public License as published by the Free
    % Software Foundation; either version 3 of the License, or (at your option)
    % any later version.
    %
    % This program is distributed in the hope that it will be useful, but
    % WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    % or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    % for more details.
    %
    % You should have received a copy of the GNU General Public License along
    % with this program; if not, write to the Free Software Foundation, Inc., 51
    % Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
    
    % Last revision on: 16.08.2012 17:30
    
    narginchk(2, 2);
    nargoutchk(0, 1);
    
    assert(factor > 0, 'OPTCont:BadArg', 'Resizing factor must be positive.');
    
    Nin = length(in(:));
    Nout = ceil(factor*Nin);
    xIn = linspace(0,1,Nin);
    xOut = linspace(0,1,Nout);
    out = interp1(xIn(:),in(:),xOut(:));
end
