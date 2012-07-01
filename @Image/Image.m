classdef Image
    %Image Represents an image in form of an n-D array.

    properties
        data = [];
    end
    
    properties (GetAccess = public, SetAccess = private)
        rows = 0;
        cols = 0;
        chan = 0;
    end
    
    properties (Dependent = true, SetAccess = private)
        pixelType
    end
        
    methods
        function obj = Image(rows,columns,varargin)
            
            error(nargchk(3, 4, nargin));
            error(nargoutchk(0, 1, nargout));

            parser = inputParser;
            
            parser.addRequired('rows', ...
                @(x) validateattributes( x, ...
                {'numeric'}, ...
                {'integer','nonnegative','scalar'}, ...
                'Image', 'rows'));
            
            parser.addRequired('columns', ...
                @(x) validateattributes( x, ...
                {'numeric'}, ...
                {'integer','nonnegative','scalar'}, ...
                'Image', 'columns'));
            
            parser.addOptional('channels', 1, ...
                @(x) validateattributes( x, ...
                {'numeric'}, ...
                {'integer','positive','scalar'}, ...
                'Image', 'channels'));
            
            parser.addOptional('type','double', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {'vector'}, ...
                'Image', 'type'));
            
            parser.parse(rows,columns,varargin{:});
            parameters = parser.Results;
            
            try
                validatestring(parameters.type, ...
                    {'double', 'single', 'int8', 'uint8', ...
                    'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'});
            catch
                ExcM = ExceptionMessage('BadClass', ...
                    horzcat( ...
                    'Cannot create image with pixels of type ', ...
                    parameters.type, ...
                    '. Will use double as fallback.'));
                warning(ExcM.id,ExcM.message);
                parameters.type = 'double';
            end
            
            obj.rows = parameters.rows;
            obj.cols = parameters.columns;
            obj.chan = parameters.channels;
            
            obj.data = squeeze(zeros( ...
                parameters.rows, parameters.columns, ...
                parameters.channels, parameters.type));
        end
        
        function pType = get.pixelType(obj)
            pType = class(obj.data);
        end

    end
    

    methods
        [rows cols channels] = size(obj)
    end
    
    methods (Access = private)
        bool = compatible(obj1,obj2)
    end
    
end

