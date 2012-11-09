function c = StochasticSparsification(f,p,q,d)

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

% Initialise with a full mask.
c = ones(size(f));
K = sum(c(:));
J = numel(f);
% Iterate until density is reached.
while K > d*J
    % Chose candidate set: max(p|K|,1) candidates.
    T = randsample(find(c),max(round(p*K),1));
    % Set candidates to 0.
    ctemp = c;
    ctemp(T) = 0;
    % Compute corresponding solution.
    u = SolvePde(f,ctemp);
    % Compute local error.
    err = (u-f).^2;
    % Put (1-q)|T| most important pixels back inside.
    S = err.*(c-ctemp); % Look among candidate set.
    n = round((1-q)*numel(T)); % Number of pixels to be placed back.
    l = numel(find(S>0))-1; % Maximal possible number of candidates.
    ctemp( FindAbsLargest(S, min(n,l)) ) = 1;
    c = ctemp;
    K = sum(c(:));
end
end
