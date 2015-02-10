classdef (Abstract = true) ScalarImage < nDGridData
    %ScalarImage Class for representing single channel images.
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
    
    properties
        p = nan(1);
    end
    
    properties (Hidden = true, Access = protected, Constant = true)
        pDim = 1; % Dimension of a pixel (number of channels), e.g. 1 for a
                  % scalar valued image, 3 for an RGB image, [3, 3] for a tensor
                  % valued image. (array of integers)
        
        isSequence = false; % Wether the image is actually a movie (logical)
    end
    
    properties (Hidden = true)
        nd = 1;
        hd = 0.0;
    end
          
    methods
        function obj = ScalarImage(nr, nc)
            
            narginchk(2, 2);
            nargoutchk(0, 1);
            
            obj = obj@nDGridData(nr, nc);
            
            obj.p = nan(obj.nr, obj.nc);
        end
        
        function obj = pad(obj, siz, varargin)
        end
        
        function obj = save(obj, fname)
        end
        
        function obj = load(obj, fname)
        end
        
        function obj = plus(obj, obj2)
            obj = plus@nDGridData(obj, obj2);
        end
        
        function val = eq(obj1, obj2)
            val = eq@nDGridData(obj1, obj2);
        end
        
    end
    
end

