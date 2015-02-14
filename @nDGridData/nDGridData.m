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
    
    % Last revision on: 13.02.2015 20:00
    
    %% Properties
    
    properties
        % Elementary properties for image structures.
        
        hr = 1.0; % Distance between two points along a row (positive scalar)
        hc = 1.0; % Distance between two points along a column (positive scalar)
        
        comment = cell(0); % Used to save textual information on the image. Note
                           % that not every image format supports comments when
                           % writing to disk.
    end
    
    properties (SetAccess = protected, GetAccess = public)
        % Elementary properties for image structures.
        
        % There is no write access to these properties to prevent its values
        % from differing of the the actual image dimensions.
        
        nr = 1; % Number of rows (positive integer)
        nc = 1; % Number of columns (positive integer)

    end
    
    properties (Dependent = true, SetAccess = private)
        br = 0; % Number of additional boundary rows on each side (nonnegative
                % integer)
        bc = 0; % Number of additional boundary columns on each side
                % (nonnegative integer)
    end
    
    properties (Abstract = true)
        p % Array containing the pixel values. Its size is adapted to target
          % image model. Thus [nr, nc] for a gray scale image, [nr, nc, pDim]
          % for a multi channel image and [nr, nc, nd, pDim] for an image
          % sequence. (array)
          
        hd % Difference between two frames. (positive scalar)
    end
        
    properties (Abstract = true, SetAccess = protected)
        nd % Number of frames. (positive integer)
    end
    
    properties (Abstract = true, Constant = true)
        % The range of possible data values is fixed and shall not differ
        % for different instances of the same class. This prevents that for
        % example an RGB image with range [0,1] gets added to an RGB image
        % with range [0, 255].
        
        rangeMin % minimal possible value in each channel (array of size pDim)
        rangeMax % maximal possible value in each channel (array of size pDim)
        colsp    % The underlying colour space (ColourSpace object)
    end
    
    properties (Abstract = true, Hidden = true, Access = protected, ...
            Constant = true)
        pDim % Dimension of a pixel (number of channels), e.g. 1 for a scalar
             % valued image, 3 for an RGB image, [3, 3] for a tensor valued
             % image. (array of integers)
        
        isIndexed  % Wether the colours are indexed via a colourmap (logical)
        isSequence % Wether the image is actually a movie (logical)
    end
    
    %% Methods
    
    methods (Abstract = true)
        load(obj, fname) % Reads image from disk.
        save(obj, fname) % Writes image to disk.
        pad(obj, siz, varargin) % Changes the dummy boundary of an image.
    end
    
    methods (Access = protected)
        function val = eqDims(obj1, obj2)
            %% Check that nr, nc, br, bc are equal.
            val = true;
            
            if ((obj1.nr ~= obj2.nr) || (obj1.nc ~= obj2.nc) || ...
                    (obj1.br ~= obj2.br) || (obj1.bc ~= obj2.bc))
                val = false;
            end
        end 
    end
    
    methods
        function obj = nDGridData(nr, nc)
            %% Constructor for nDGridData.
            %
            % obj = nDGridData(nr, nc, varargin)
            %
            % Input parameters (required):
            %
            % nr : Number of rows. (positive integer)
            % nc : Number of coloumns. (positive integer)
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
            
            narginchk(2, 2);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('nr', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nr'));
            
            parser.addRequired('nc', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nc'));
                        
            parser.parse(nr, nc);
            
            obj.nr = parser.Results.nr;
            obj.nc = parser.Results.nc;
            
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
                
        function br = get.br(obj)
            % Sets the number of boundary rows. If the input is negative, its
            % absolute value is taken. If the number is non-integer, it is
            % rounded.
            
            br = (size(obj.p, 1) - obj.nr)/2;
        end
        
        function bc = get.bc(obj)
            % Sets the number of boundary coloumns. If the input is negative,
            % its absolute value is taken. If the number is non-integer, it is
            % rounded.
            
            bc = (size(obj.p, 2) - obj.nc)/2;
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
                                
        %% Implementation of arithmetic operations for images.
        % All arithmetic operations require that the involved dimensions nr, nc,
        % br and bc match. No check on hr and hc is done. Should such a check be
        % necessary, then it can always be done in a subclass. Also operations
        % on arrays and images do not have any size check since it is not
        % possible to know what is image and what is boundary.
        
        function val = eq(obj1, obj2)
            %% Check that all nDGridData properties are equal.
            val = true;
            
            if ( ~eqDims(obj1, obj2) || ...
                    (obj1.hr ~= obj2.hr) || (obj1.hc ~= obj2.hc) )
                val = false;
            end
        end

        
        function obj = plus(obj, obj2)
            %% Addition of two images. All dimensions must agree.
            
            % Check argument types so that we can handle any imaginable case of
            % combinations like 3 + q, q + 3 and q + p, where q and p are
            % images. Note that either obj or obj2 must be an image. Otherwise
            % this method isn't called.
            if isnumeric(obj)
                obj = plus(obj2, obj);
            elseif isnumeric(obj2)
                obj.p = obj.p + obj2;
            elseif eqDims(obj, obj2)
                obj.p = obj.p + obj2.p;
            else
                MExc = ExceptionMessage('BadDim', ...
                    'message', 'Image Dimensions do not match.');
                error(MExc.id, MExc.message);
            end
        end
        
        function obj = uplus(obj)
            %% Unary plus
            obj.p = uplus(obj.p);
        end
        
        function obj = minus(obj, obj2)
            %% Substraction of two images. All dimensions must agree.
            
            % Check argument types so that we can handle any imaginable case of
            % combinations like 3 - q, q - 3 and q - p, where q and p are
            % images. Note that either obj or obj2 must be an image. Otherwise
            % this method isn't called.
            if isnumeric(obj)
                obj = uminus(minus(obj2, obj));
            elseif isnumeric(obj2)
                obj.p = obj.p - obj2;
            elseif eqDims(obj, obj2)
                obj.p = obj.p - obj2.p;
            else
                MExc = ExceptionMessage('BadDim', ...
                    'message', 'Image Dimensions do not match.');
                error(MExc.id, MExc.message);
            end
        end
                
        function obj = uminus(obj)
            %% Unary minus
            obj.p = uminus(obj.p);
        end
        
        function obj = times(obj, obj2)
            %% Pointwise product of two images. All dimensions must agree.
            
            % Check argument types so that we can handle any imaginable case of
            % combinations like 3 .* q, q .* 3 and q .* p, where q and p are
            % images. Note that either obj or obj2 must be an image. Otherwise
            % this method isn't called.
            if isnumeric(obj)
                obj = times(obj2, obj);
            elseif isnumeric(obj2)
                obj.p = obj.p .* obj2;
            elseif eqDims(obj, obj2)
                obj.p = obj.p .* obj2.p;
            else
                MExc = ExceptionMessage('BadDim', ...
                    'message', 'Image Dimensions do not match.');
                error(MExc.id, MExc.message);
            end
        end
                        
        function out = mtimes(obj, obj2)
            MExc = ExceptionMessage('Unsupported');
            error(MExc.id, MExc.message);
        end
        
        function out = rdivide(obj, obj2)
            MExc = ExceptionMessage('Unsupported');
            error(MExc.id, MExc.message);
        end
        
        function out = ldivide(obj, obj2)
            MExc = ExceptionMessage('Unsupported');
            error(MExc.id, MExc.message);
        end
                
        function out = transpose(obj)
            MExc = ExceptionMessage('Unsupported');
            error(MExc.id, MExc.message);
        end
        
        % Redefining subsagn and subsref makes properties visible that are
        % actually private. According to the matlab documentation there's no way
        % around this at the moment. Each case must be handled individually. 
%         function sref = subsref(obj, s)
%             %% obj(i) is equivalent to obj.p(i)
%             switch s(1).type
%                 case '.'
%                     %% Use the built-in subsref for dot notation
%                     % TODO: protected access still fails.
%                     % Maybe this will be too complex and too much computational
%                     % overhead to handle.
%                     mc = metaclass(obj);
%                     mcp = findobj(mc.PropertyList, 'Name', s(1).subs);
%                     if strcmpi(mcp.GetAccess, 'public')
%                         sref = builtin('subsref', obj, s);
%                     else
%                         MExc = ExceptionMessage('Input', ...
%                             'message', 'Property is not public.');
%                         error(MExc.id, MExc.message);
%                     end
%                 case '()'
%                     if length(s)<2
%                         %% Note that obj.p is passed to subsref
%                         sref = builtin('subsref', obj.p, s);
%                         return
%                    else
%                         sref = builtin('subsref', obj, s);
%                     end
%                 case '{}'
%                     %% No support for indexing using '{}'
%                     MExc = ExceptionMessage('BadArg', ...
%                         'message', 'Subscripted reference not supported.');
%                 error(MExc.id, MExc.message);
%             end
%         end
        
%         function obj = subsasgn(obj, s, val)
%             if isempty(s) && isa(obj, 'nDGridData')
%                 % ?
%             end
%             switch s(1).type
%                 case '.'
%                     %% Use the built-in subsasagn for dot notation
%                     obj = builtin('subsasgn', obj, s, val);
%                 case '()'
%                     if length(s)<2
%                         if isa(val, 'nDGridData')
%                             MExc = ExceptionMessage('BadArg', ...
%                                 'message', 'Assignment not supported.');
%                             error(MExc.id, MExc.message);
%                         else
%                             % Redefine s to make the call to obj.Data(i)
%                             snew = substruct('.', 'p', '()', s(1).subs(:));
%                             obj = subsasgn(obj, snew, val);
%                         end
%                     end
%                 case '{}'
%                     %% No support for indexing using '{}'
%                     MExc = ExceptionMessage('BadArg', ...
%                         'message', 'Subscripted assignment not supported.');
%                     error(MExc.id, MExc.message);
%             end
%         end
        
    end % end methods
    
end % end classdef

