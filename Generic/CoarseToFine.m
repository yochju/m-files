function out = CoarseToFine(in,factor,NSample)
    %Computes a coarse to fine representation of a given signal.
    
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
    
    narginchk(3, 3);
    nargoutchk(0, 1);
    
    out = { in(:) };
    
    if factor == 1
        return
    elseif factor > 1
        assert( NSample > length(in(:)) );
        
        new = ChangeResolution(in(:),factor);
        i = 1;
        while length(new(:)) <= NSample
            i = i + 1;
            if length(new(:)) > length(out{end})
                out{end+1} = new(:);
            end
            new = ChangeResolution(in(:),factor^i);
        end
        
    else
        assert( NSample < length(in(:)) );
        
        new = ChangeResolution(in(:),factor);
        i = 1;
        while length(new(:)) >= NSample
            i = i + 1;
            if length(new(:)) < length(out{end})
                out{end+1} = new(:);
            end
            new = ChangeResolution(in(:),factor^i);
        end
    end
    out = fliplr(out);
end