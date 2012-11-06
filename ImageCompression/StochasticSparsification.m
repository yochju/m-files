function c = StochasticSparsification(f,p,q,d)
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
