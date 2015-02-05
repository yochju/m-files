classdef DoubleImage < ScalarImage
    %RasterImage Class for representing single channel images.
    %   Detailed explanation goes here
        
    % Copyright 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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
    
    % Last revision on: 02.02.2015 16:00
    
    properties (Constant = true)
        rangeMin = 0;
        rangeMax = 1;
    end
    
    properties (Hidden = true, Access = protected, Constant = true)        
        isIndexed = false; % Wether the colours are indexed via a colourmap (logical)
    end
    
    properties
        colsp = ColourSpace.None;
    end
              
    methods
        function obj = DoubleImage(nr, nc, varargin)
            
            narginchk(2, 4);
            nargoutchk(0, 1);
            
            obj = obj@ScalarImage(nr, nc);
        end
        
        %function obj = plus(obj, obj2)
        %    obj.p = obj.p + obj2.p;
        %end
        
        function obj = plus(obj, obj2)
            obj = plus@ScalarImage(obj, obj2);
        end
        
        function val = eq(obj1, obj2)
            val = eq@ScalarImage(obj1, obj2);
            if (val)
                if (max(abs(obj1.p(:)-obj2.p(:))) >= 1e-10)
                    val = false;
                end
            end
        end
                
    end
    
end

