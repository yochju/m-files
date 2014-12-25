function [p pval pg i] = solvedual(A, B, f, ubar, cbar, g, lambda, theta, epsi, maxit)
% Gradient descent scheme to find the optimal solution for the dual problem.
% Returns:
% p - minimiser.
% pval - minimum.
% pg - gradient.

% Initialisation with 0.
p = zeros(size(B(:)));

i = 1;
while(i<maxit)
    % Compute optimal step size.
    [alpha q qval] = optimalstep(p, A, B, f, ubar, cbar, g, lambda, theta, epsi);
    
    % Save old position and old function value.
    pOld = p;
    fval = h3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi);
    
    p = q;
    pval = qval;
    pg = nablah3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi);
    if(norm(pg)<0.001)
        break;
    end
    % Compute new position.
%     p = p - alpha*nablah3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi);
%     pg = nablah3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi);
%     if(norm(p-q)>0.001)
%         % Should be equal to q.
%         warning('1-???: %d',norm(p-q));
%     end
    
    % Compute corresponding function value.
%     pval = h3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi);
%     if(norm(qval-pval)>0.001)
%         % Should be equal to q.
%         warning('2-???: %d',norm(qval-pval));
%     end
    
    % Stop if gradient gets to small.
    if(norm(p)<0.0001)
        break;
    end
    
    if (pval >= fval)
        warning('This should not happen in solvedual: %d!',abs(pval-fval));
    end
    
    check2 = norm(p-pOld);
    if(check2<0.001)
        break;
    end
    i = i + 1;
end
end
