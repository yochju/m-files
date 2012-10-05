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
    
    % Last revision on: 05.10.2012 07:30
    
    % TODO: Check ME = MException(identifier, string).
    
    properties
        id      = ''; % Identifier for the message.
        message = ''; % Corresponding message.
    end
    
    properties (Constant, GetAccess = private)
        ExceptionCode = ExceptionMessage.Exceptions(); % Struct with messages.
    end
    
    methods
        function obj = ExceptionMessage(type,varargin)
            % Constructor.
            
            narginchk(1, 5);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('type', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {'vector'}, ...
                'ExceptionMessage', 'type'));
                        
            parser.addParamValue('message', '', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {'nonsparse'}, ...
                'ExceptionMessage', 'message'));
            
            parser.parse(type,varargin{:});
            parameters = parser.Results;
            
            if ~any(strcmp(parameters.type,ExceptionMessage.ExceptionTypes()))
                ExcM = ExceptionMessage( ...
                    'Input', ...
                    'message', ...
                    horzcat( ...
                    'Cannot create Exception message for type ', ...
                    parameters.type, ...
                    '. Will use Generic as fallback.') ...
                    );
                warning(ExcM.id, ExcM.message);
                parameters.type = 'Generic';
            end
                        
            % This should give me the name of the calling function.
            [ST, ~] = dbstack(1);
            
            if isempty(ST(1).name)
                % If the stack is empty, there was no calling function.
                obj.id = parameters.type;
            else
                % Called from within some function. If that function was a
                % method of some class, we replace the '.' by a ':' and append
                % the type.
                obj.id = horzcat( ...
                    regexprep(ST(1).name,'\.',':') , ':', parameters.type);
            end
                        
            if ~isempty(parameters.message)
                obj.message = parameters.message;
            else
                obj.message = obj.ExceptionCode.(parameters.type);
            end
                        
        end
    end
    
    methods (Static = true)
        function exceptionStruct = Exceptions()
            exceptionStruct = struct( ...
                'Generic',     'Unspecified problem.', ...
                'NumArg',      'Wrong number of arguments.', ...
                'Input',       'Invalid input value.', ...
                'Missing',     'Missing input data.', ...
                'UnknownOp',   'Unknown operation required.', ...
                'BadArg',      'Unexpected argument value.', ...
                'BadDim',      'Data has wrong size.', ...
                'BadClass',    'Unknown data class required.', ...
                'Internal',    'An internal error occured.', ...
                'NotFound',    'Cannot find file.', ...
                'NoField',     'Not a field of this struct.', ...
                'Unsupported', 'This operation is not yet supported.' ...
                );
        end
        
        function types = ExceptionTypes()
            types = fieldnames(ExceptionMessage.Exceptions());
        end
        
    end
    
end
