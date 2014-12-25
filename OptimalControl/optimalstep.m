function [res q qval] = optimalstep(p, A, B, f, ubar, cbar, g, lambda, theta, epsi)
% Finds the optimal stepsize for the gradient descent scheme to solve the dual
% of the linearised optimal control problem.
%
% Returns res (=optimal step length), q (=current position for the minimum) and
% qval (=corresponding function value)

res = 2;
t0 = p - res*nablah3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi);
r0 = h3(t0, A, B, f, ubar, cbar, g, lambda, theta, epsi);

while(res > 0.000001)
    % Update step size.
    res = 0.9*res;
    
    % Compute new position.
    t1 = p - res*nablah3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi);
    
    % Check function value
    r1 = h3(t1, A, B, f, ubar, cbar, g, lambda, theta, epsi);
    
    if(r1 > r0)
        % No further minimization was possible. Stop.
        q = t0;
        qval = r0;
        break;
    else
        t0 = t1;
        r0 = r1;
        q = t1;
        qval = r1;
    end
end
end
