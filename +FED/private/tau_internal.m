function out = tau_internal(n, scale, tau_max, reordering)

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

% Last revision on: 31.10.2012 9:00


tau = nan(1,n);
c = 1/(4*n+2);
d = scale*tau_max/2.0;
FED_MAXKAPPA = 6000;

if reordering
    tauh = d./cos(pi*(1:2:2*n)*c).^2;
    if n > FED_MAXKAPPA
        % This should emit a warning.
        kappa = n/4;
    else
        kappa = kappalookup(n+1);
    end
    prime = n+1;
    
    while ~isprime(prime)
        prime = prime + 1;
    end
    
%     Original C code;
%     for (k = 0, l = 0; l < n; ++k, ++l)
%     {
%       int index;
%       while ((index = ((k+1)*kappa) % prime - 1) >= n)
%         k++;
% 
%       (*tau)[l] = tauh[index];
%     }
%   }
    
    k = 0;
    while k>-1
        for l = 0:(n-1)
            index = mod((k+1)*kappa,prime)-1;
            while index >= n
                k = k+1;
                index = mod((k+1)*kappa,prime)-1;
            end
            tau(l+1) = tauh(index+1);
            k = k+1;
        end
        break;
    end
    
else
    tau = d./cos(pi*(1:2:2*n)*c).^2;
end
out = tau;
end
