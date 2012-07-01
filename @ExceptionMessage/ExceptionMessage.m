classdef ExceptionMessage
    %ExceptionMessage Generates ids and messages for warnings and errors.
    %    Generates id codes and corresponding messages that can be used in
    %    combination with warning() and error().
    %
    %    ExceptionMessage(type) returns an object with the id and message
    %    corresponding to type.
    %    ExceptionMessage(type,message) returns an object with the id
    %    corresponding to type, but where the default message has been
    %    superseded by the one specified.
    %    The possible types and their corresponding default messages can be
    %    queried using the static methods Exceptions and ExceptionsTypes.
    %
    %    See also: warning, error
    
    properties
        id = '';
        message = '';
    end
    
    properties (Constant, GetAccess = private)
        ExceptionCode = ExceptionMessage.Exceptions();
    end
    
    methods
        function obj = ExceptionMessage(type,varargin)
            
            error(nargchk(1, 2, nargin));
            error(nargoutchk(0, 1, nargout));

            parser = inputParser;
            
            parser.addRequired('type', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {'vector'}, ...
                'ExceptionMessage', 'type'));
            
            parser.addOptional('message','', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {'vector'}, ...
                'Image', 'type'));
            
            parser.parse(type,varargin{:});
            parameters = parser.Results;
            
            try
                validatestring(parameters.type, ...
                    ExceptionMessage.ExceptionTypes());
            catch
                ExcM = ExceptionMessage('Input', ...
                    horzcat( ...
                    'Cannot create Exception message for type ', ...
                    parameters.type, ...
                    '. Will use Generic as fallback.'));
                warning(ExcM.id,ExcM.message);
                parameters.type = 'Generic';
            end
            
            info = dbstack();
            obj.id = horzcat( ...
                regexprep(info(end).name,'\.',':'), ...
                ':', ...
                parameters.type);
            
            if nargin == 2
                obj.message = parameters.message;
            else 
                obj.message = obj.ExceptionCode.(parameters.type);
            end
            
        end
    end
    
    methods (Static = true)
        function exceptionStruct = Exceptions()
            exceptionStruct = struct( ...
                'Generic', 'Unspecified problem.', ...
                'NumArg', 'Wrong number of arguments.', ...
                'Input',  'Invalid input value.', ...
                'BadClass', 'Unknown data class required.' ...
                );
        end
        
        function types = ExceptionTypes()
            types = fieldnames(ExceptionMessage.Exceptions());
        end
        
    end
        
end