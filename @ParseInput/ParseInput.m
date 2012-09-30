classdef ParseInput < inputParser
    
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
                        'BadArg', ...
                        'If specified, argument must be 1d String' );
                    error(MExc.id, MExc.message);
                end
            end
            
        end
        
    end
    
end

