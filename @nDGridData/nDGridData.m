classdef (Abstract = true) nDGridData
    %nDGridData: Abstract base class defining common properties to all images.
    % Abstract class containing properties common to all image structures to are
    % derived from this class.
    
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
    
    % Last revision on: 01.02.2015 20:00
    
    properties
        % Elementary properties for image structures.
        
        nr = 1; % Number of rows (positive integer)
        nc = 1; % Number of columns (positive integer)
        
        br = 0; % Number of additional boundary rows on each side (nonnegative
        % integer)
        bc = 0; % Number of additional boundary columns on each side
        % (nonnegative integer)
        
        hr = 1.0; % Distance between two points along a row (positive scalar)
        hc = 1.0; % Distance between two points along a column (positive scalar)
        
        comment = cell(0); % Used to save textual information on the image. Note
                           % that not every image format supports comments when
                           % writing to disk.
    end
    
    properties (Abstract = true)
        p % Array containing the pixel values. Its size is adapted to target
          % image model. Thus [nr, nc] for a gray scale image, [nr, nc, pDim]
          % for a multi channel image and [nr, nc, nd, pDim] for an image
          % sequence. (array)
        
        nd % Number of frames. (positive integer)
        hd % Difference between two frames. (positive scalar)
    end
    
    properties (Abstract = true, Constant = true)
        % The range of possible data values is fixed and shall not differ
        % for different instances of the same class. This prevents that for
        % example an RGB image with range [0,1] gets added to an RGB image
        % with range [0, 255].
        
        rangeMin % minimal possible value in each channel (array of size pDim)
        rangeMax % maximal possible value in each channel (array of size pDim)
    end
    
    properties (Abstract = true, Hidden = true, Access = protected, ...
            Constant = true)
        pDim % Dimension of a pixel (number of channels), e.g. 1 for a scalar
             % valued image, 3 for an RGB image, [3, 3] for a tensor valued
             % image. (array of integers)
        
        isIndexed  % Wether the colours are indexed via a colourmap (logical)
        isSequence % Wether the image is actually a movie (logical)
    end
    
    methods (Abstract = true)
        load(obj, fname) % Reads image from disk.
        save(obj, fname) % Writes image to disk.
        pad(obj, siz, varargin) % Changes the dummy boundary of an image.
    end
    
    methods
        function obj = nDGridData(nr, nc, varargin)
            %% Constructor for nDGridData.
            %
            % obj = nDGridData(nr, nc, varargin)
            %
            % Input parameters (required):
            %
            % nr : Number of rows. (positive integer)
            % nc : Number of coloumns. (positive integer)
            %
            % Input parameters (optional):
            %
            % br : Number of boundary rows on each side (nonnegative integer)
            % bc : Number of boundary coloumns on each side (nonnegative
            %      integer)
            % hr : Distance between two pixels along a row. (positive scalar)
            % hc : Distance between two pixels along a coloumn. (positive
            %      scalar)
            %
            % Output parameters:
            %
            % obj : A nDGridData object with the specified or default
            % values.
            %
            % Description:
            %
            % Serves as superclass constructor for specialised subclasses
            % that need an initialisation in their own constructors. Note
            % that this class is abstract and therefore cannot be
            % instantiated.
            %
            % Example:
            %
            % Inside the constructor of a derived subclass call
            %
            % obj = obj@nDGridData(nr, nc);
            %
            % to create an object with nr rows, nc coloumns, and default
            % values for all the other properties.
            
            %% Parse the inputs passed to the constructor.
            
            narginchk(2, 6);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('nr', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nr'));
            
            parser.addRequired('nc', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nc'));
            
            parser.addOptional('br', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'nDGridData', 'br'));
            
            parser.addOptional('bc', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'nDGridData', 'bc'));
            
            parser.addOptional('hr', 1.0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'positive'}, ...
                'nDGridData', 'hr'));
            
            parser.addOptional('hc', 1.0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'positive'}, ...
                'nDGridData', 'hc'));
            
            
            parser.parse(nr, nc, varargin{:});
            
            obj.nr = parser.Results.nr;
            obj.nc = parser.Results.nc;
            
            obj.br = parser.Results.br;
            obj.bc = parser.Results.bc;
            
            obj.hr = parser.Results.hr;
            obj.hc = parser.Results.hc;
        end % end nDGridData
        
        function obj = set.nr(obj, val)
            % Sets the number of rows. If the input is negative, its absolute
            % value is taken. If the number is non-integer, it is rounded. If it
            % is 0, 1 is returned.
            
            obj.nr = max(1, round(abs(val)));
        end
        
        function obj = set.nc(obj, val)
            % Sets the number of coloumns. If the input is negative, its
            % absolute value is taken. If the number is non-integer, it is
            % rounded. If it is 0, 1 is returned.
            
            obj.nc = max(1, round(abs(val)));
        end
        
        function obj = set.br(obj, val)
            % Sets the number of boundary rows. If the input is negative, its
            % absolute value is taken. If the number is non-integer, it is
            % rounded.
            
            obj.br = round(abs(val));
        end
        
        function obj = set.bc(obj, val)
            % Sets the number of boundary coloumns. If the input is negative,
            % its absolute value is taken. If the number is non-integer, it is
            % rounded.
            
            obj.bc = round(abs(val));
        end
        
        function obj = set.hr(obj, val)
            % Sets the distance between points along a row. If the input is
            % negative, its absolute value is taken. If the number is
            % non-integer, it is rounded.
            
            obj.hr = abs(val);
        end
        
        function obj = set.hc(obj, val)
            % Sets the distance between points along a coloumn. If the input is
            % negative, its absolute value is taken. If the number is
            % non-integer, it is rounded.
            
            obj.hc = abs(val);
        end
        
    end % end methods
end % end classdef

