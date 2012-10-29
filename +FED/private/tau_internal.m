function out = tau_internal(n, scale, tau_max, reordering)

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
        kappa = kappalookup(n);
    end
    prime = n+1;
    
    while ~isprime(prime)
        prime = prime + 1;
    end
    
    k = 0;
    while k>-1
        for l = 1:n
            index = mod((k+1)*kappa,prime)-1;
            while index >= n
                k = k+1;
            end
            tau(l) = tauh(index);
        end
    end
    
else
    tau = d./cos(pi*(1:2:2*n)*c).^2;
end
out = tau;
end
