function sOut = PeriodicExtension( sIn , dim , repetitions , mirror )
% Extends signal periodically (with and without) mirroring.
%
% PeriodicExtension extends the signal either without or with mirroring. The
% size of the extensions can be specified through the number of repetitions.
%
% Example
% Extend with mirroring.
% PeriodicExtension( 1:10 , 1 , 2 , true )
%
% See also fliplr, flipud, flipdim

% Copyright 2011, 2012, 2013 Laurent Hoeltgen <hoeltgman@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
% MA 02110-1301, USA.

% Last revision on: 24.04.2013 09:40

narginchk(2,4);
nargoutchk(0,1);

if nargin < 2
    dim = 1;
    if nargin < 3
        repetitions = 1;
        if nargin < 4
            mirror = true;
        end
    end
end

sOut = sIn;
for i = 1:repetitions
    if mirror == false
        sOut = cat(dim, sOut, sIn);
    else
        if mod(i,2) == 1
            sOut = cat(dim, sOut, flipdim(sIn,dim));
        else
            sOut = cat(dim, sOut, sIn);
        end
    end
end

end
