classdef ExceptionMessage
    %ExceptionMessage generates ids and messages for warnings and errors.
    %    Generates id codes and corresponding messages that can be used in
    %    combination with warning(), assert() and error(). It is not a
    %    replacement for the MException class. ExceptionMessage is only meant to
    %    provide a consistent way for using identifiers and messages that are
    %    required by MException.
    %
    %    The message types that can be used are hardcoded inside the class, each
    %    one with a corresponding default message (which can be changed). The
    %    possible types and their corresponding default messages can be queried
    %    using the static methods Exceptions and ExceptionsTypes.
    %
    %    See also: warning, assert, error
    
    % Copyright 2012-2016 Laurent Hoeltgen <hoeltgen@b-tu.de>
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
    
    % Last revision on: 2016-01-31 16:00
    
    properties
        id      = ''; % Identifier for the message.
        message = ''; % Corresponding message.
    end
    
    properties (Constant, GetAccess = private)
        ExceptionCode = ExceptionMessage.Exceptions(); % Struct with messages.
    end
    
    methods
        function obj = ExceptionMessage(type, varargin)
            %% Creates a new instance of the class ExceptionMessage.
            %
            % obj = ExceptionMessage(type,varargin)
            %
            % Input parameters (required):
            %
            % type : String specifying the type of Message to be generated. Use
            %        the static method ExceptionMessage.ExceptionTypes() to
            %        obtain a list of possible choices. If the type is unknown
            %        to the class, it will be replaced by 'Generic'.
            %
            % Input parameters (optional):
            %
            % Optional parameters are either struct with the following fields
            % and corresponding values or option/value pairs, where the option
            % is specified as a string.
            %
            % message : A string containing the message to be used. Every type
            %           has a default message. This parameter is meant to
            %           override this default in order to provide further
            %           details.
            %
            % Output parameters:
            %
            % obj : An instance of the ExceptionMessage class with its field
            %       'id' containing the id corresponding to the specified type
            %       and the field 'message' containing either the default
            %       message string or the one specified by the user.
            %
            % Description:
            %
            % The message field, if specified, is used as-is and not altered in
            % any way during the contruction. The id is constructed as follows.
            %
            % id = [<class>:]<method>:<type>
            %
            % where:
            % - <type> represents the message type that was passed during
            %   construction.
            % - <method> is the name of the method that is constructing the
            %   instance. If no such method is found, then the string 'CONSOLE'
            %   will be prepended. If the calling function is a class method,
            %   then the name of the class will also be prepended (and split
            %   from the method name by a colon).
            % - <class> is the name of the potential class the calling method
            %   belongs to. This string as well as the corresponding colon are
            %   left away if unavailable.
            %
            % Example:
            %
            % Query the possible choices for the exception types.
            %
            %   Types = ExceptionMessage.ExceptionTypes();
            %
            % Chose for example the 'NumArg' type.
            %
            %   MExc = ExceptionMessage('NumArg', 'message', 'Some Message.');
            %
            % Generate a warning using the above object.
            %
            %   warning(MExc.id, MExc.message);
            %
            % Check that the id and message are correct.
            %
            %   [msg id] = lastwarn;
            
            %% Parse the inputs passed to the constructor.
            
            narginchk(1, 5);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('type', ...
                @(x) validateattributes( x, ...
                {'char'}, ...
                {'vector'}, ...
                'ExceptionMessage', 'type'));
            
            parser.addParameter('message', '', ...
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
            
            %% Gather the necessary information.
            
            % This should give me the name of the calling function.
            [ST, ~] = dbstack(1);
            
            if isempty(ST)
                % If the stack is empty, there was no calling function. In that
                % case we prepend the id with CONSOLE.
                obj.id = horzcat( ...
                    'CONSOLE:', parameters.type);
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
            %% Returns a struct containing all possible types and messages.
            %
            % exceptionStruct = ExceptionMessage.Exceptions()
            
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
            %% Returns a cell array containing all possible types.
            %
            % types = ExceptionMessage.ExceptionTypes()
            
            types = fieldnames( ExceptionMessage.Exceptions() );
        end
        
    end
    
end
