function out = NextCombination(in)
%% Returns the next element in an ordered way of a binary array sequence.
%
% out = NextComb(in)
%
% Input parameters (required):
%
% in : 1D array of binary values.
%
% Input parameters (optional):
%
%
%
% Output parameters:
%
% out : the next element in the logical ordering of the sequence.
%
% Description:
%
% Takes as input an array of the form [0 0 1 1 0 0 1] and returns the next
% element of the sequence such that starting from [0 0 0 0 1 1 1] all
% combinations can be tranversed. The last one will be [1 1 1 0 0 0 0]. The
% sequence is as follows:
%
% ...
% [0 0 1 1 0 0 1]
% [0 1 0 1 0 0 1]
% [1 0 0 1 0 0 1]
% [0 1 1 0 0 0 1]
% [1 0 1 0 0 0 1]
% [1 1 0 0 0 0 1]
% [0 0 0 1 1 1 0]
% [0 0 1 0 1 1 0]
% ...
%
% If the last element of the sequence is reached, the algorithm simply returns
% that element. The input can be a row or a column vector.
%
% Example
%
% Nextcomb([0 0 1]) yields [0 1 0].

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

% Last revision on: 14.09.2012 11:26

%% Check input parameters.

narginchk(1, 1);
nargoutchk(0, 1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('in', ...
    @(x) validateattributes(x, {'numeric'}, {'vector','binary'}, ...
    mfilename, 'in', 1));

parser.parse(in);
opts = parser.Results;

%% Algorithm

out = opts.in(:);

% Find the first occurence of a 1.
leading1 = find(out,1,'first');

if leading1 == 1
    %% Tricky case.
    % The array starts with a sequence of 1s. The will come a certain number of
    % 0 and maybe another 1.
    
    % p denotes the position of the first 1 of the second block of 1s. If p is
    % empty, there is now second block of 1s. In that case, we have reached the
    % final combination.
    p = find(diff(out)==1,1,'first') + 1;
    
    if ~isempty(p)
        %% A second block of 1s exist.
        
        % Shift the first 1 of that block one position to the left.
        out(p-1) = 1;
        out(p) = 0;
        
        startblock = find(diff(out) == -1, 1, 'first') + 1;
        if startblock < p
            %% First two blocks were separated by several 0s.
            
            % The check here is necessary to exclude cases like
            % [1 0 1 0 0 1] -> [1 1 0 0 0 1]
            % where we should not move any blocks of 0s.
            
            endblock   = find(diff(out) ==  1, 1, 'first');
            out(startblock:endblock) = [];
            out = [zeros(endblock-startblock+1,1) ; out(:)];
        end

    end
    
else
    %% Easy case.
    
    % The array starts with 0s. Simply shift the the first 1 one position to the
    % left.
    out(leading1-1) = 1;
    out(leading1)   = 0;
end

end
