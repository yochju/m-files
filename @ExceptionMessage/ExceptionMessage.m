classdef ExceptionMessage
    %ExceptionMessage Generates ids and messages for warnings and errors.
    %    Generates id codes and corresponding messages that can be used in
    %    combination with warning() and error().
    %
    %    ExceptionMessage(type) returns an object with the id and message
    %    corresponding to type. If the type is unknown, a warning will be issued
    %    and the "Generic" type will be used as a fallback.
    %
    %    ExceptionMessage(type,class) additionnally prepends the class to the
    %    identifier. If class is an empty string, it will be ignored. If the
    %    class is unknown, a warning is issued and it will be replaced by ''.
    %
    %    ExceptionMessage(type,class,message) also sets the message to the
    %    corresponding argument.
    %
    %    The possible types and their corresponding default messages can be
    %    queried using the static methods Exceptions and ExceptionsTypes.
    %
    %    See also: warning, error
    %
    % ExceptionMessage Properties:
    % id - identifier for the message.
    % message - Corresponding message.
    %
    % ExceptionMessage Methods:
    % ExceptionMessage - This is the constructor.
    % Exceptions - Returns a struct containing all valid messages.
    % ExceptionTypes - returns a cell array containing all valid types.
    
    properties
        id = ''; % Identifier for the message.
        message = ''; % Corresponding message.
    end
    
    properties (Constant, GetAccess = private)
        ExceptionCode = ExceptionMessage.Exceptions(); % Struct with messages.
    end
    
    methods
        function obj = ExceptionMessage(type,varargin)
            % Constructor.
            
            error(nargchk(1, 3, nargin));
            error(nargoutchk(0, 1, nargout));
            
            parser = inputParser;
            
            parser.addRequired('type', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {'vector'}, ...
                'ExceptionMessage', 'type'));
            
            parser.addOptional('class','', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {}, ...
                'ExceptionMessage', 'type'));
            
            parser.addOptional('message','', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {'vector'}, ...
                'ExceptionMessage', 'type'));
            
            parser.parse(type,varargin{:});
            parameters = parser.Results;
            
            if ~any(strcmp(parameters.type,ExceptionMessage.ExceptionTypes()))
                ExcM = ExceptionMessage('Input', 'ExceptionMessage', ...
                    horzcat( ...
                    'Cannot create Exception message for type ', ...
                    parameters.type, ...
                    '. Will use Generic as fallback.'));
                warning(ExcM.id,ExcM.message);
                parameters.type = 'Generic';
            end
            
            if exist(parameters.class,'class') == 8
                ExcM = ExceptionMessage('BadClass', 'ExceptionMessage', ...
                    horzcat( ...
                    'Classname ', parameters.class, ' is unknown.', ...
                    '. Will use empty string as fallback.'));
                warning(ExcM.id,ExcM.message);
                parameters.class = '';
            end
            
            if isempty(parameters.class)
                obj.id = parameters.type;
            else
                obj.id = horzcat( parameters.class, ':', parameters.type);
            end
            
            if nargin == 3
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
                'UnknownOp', 'Unknown operation required.', ...
                'BadDim', 'Data has wrong size.', ...
                'BadClass', 'Unknown data class required.', ...
                'Internal', 'An internal error occured.', ...
                'Unsupported', 'This operation is not yet supported.' ...
                );
        end
        
        function types = ExceptionTypes()
            types = fieldnames(ExceptionMessage.Exceptions());
        end
        
    end
    
end