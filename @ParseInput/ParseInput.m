classdef ParseInput < inputParser

    % Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 09.10.2012 15:50
    
    properties
        % TODO Set Setaccess to private and getaccess to public.
        % Add a NumArg property (dependent) that returns the total number of
        % args.
        numReq = 0;
        numOpt = 0;
        numPar = 0;
        numOut = 1;
    end
    
    methods
        % TODO some of the methods could benefit from try catch blocks...
        function object = ParseInput(funName)
            
            narginchk(0,1);
            nargoutchk(0,1);
            
            % Initialise super class.
            object@inputParser();
            
            % argument matches should be case sensitive.
            object.CaseSensitive = true;
            
            % keep unmatched parameters inside the object. This way we can pass
            % options to methods defined inside methods by just passing the
            % initial inputParser object.
            object.KeepUnmatched = true;
            
            % Whether to interpret a structure array as a single input or as a
            % set of parameter name and value pairs.
            object.StructExpand = true;
            
            % the function name to be included in the error messages. If no
            % argument is specified and if the object was created inside a
            % function, that function name will be used. Otherwise it will be an
            % empty string.
            if nargin == 1
                if IsString(funName)
                    object.FunctionName = funName;
                else
                    MExc = ExceptionMessage( ...
                        'BadArg', 'message', ...
                        'If specified, argument must be 1d String' );
                    error(MExc.id, MExc.message);
                end
            end
            
        end
        
    end
    
end

