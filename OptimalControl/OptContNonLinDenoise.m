function [u, c, eArr] = OptContNonLinDenoise(f, lambda, mu, theta, outer, inner)
%
% Solves: argmin_{u,c} lambda/2||u-f||^2 + mu/2||c||^2
%         such that c.*(u-f) - (1-c).*Du = 0

% Image Size and Number or pixels.
[nr nc] = size(f);
N = nr*nc;

% Initialise Mask and Signal somewhere in the middle.
% Unsure if this is ok or not.
c = ones(size(f));
u = f;

c = c(:);
u = u(:);
f = f(:);

% Array for storing energy values.
eArr = inf(1,outer*inner);

for k = 1:outer

    % Update data for diffusion tensor.
    v = reshape(u, [nr nc]);
    
    for j = 1:inner
        
        % Save old position for Taylor expansion.
        cbar = c;
        ubar = u;
        
        S = IsoDiffStencil(v, ...
            'sigma', opts.sigma, ...
            'diffusivity', opts.diffusivity, ...
            'diffusivityfun', opts.diffusivityfun, ...
            'gradmag', opts.gradmag );
        
        D = Stencil2Mat(S, 'boundary', 'Neumann');
        
        A = spdiags( cbar(:), 0, N, N) - spdiags( 1 - cbar(:), 0, N, N)*D;
        B = spdiags( ubar(:) - f(:) + D*ubar(:), 0, N, N);
        g = A*ubar(:) + B*cbar(:) - ...
            cbar(:).*(ubar(:) - f(:)) - (1 - cbar(:))*D*ubar(:);
        
        % Set up the linear system to obtain the dual variable.
        LHS = (1/(lambda+theta))*(A*(A')) + (1/(mu+theta))*(B*(B'));
        RHS = (1/(lambda+theta))*A*(lambda*f+theta*ubar) + ...
            (1/(mu+theta))*B*(mu*g+theta*cbar) - g;
        
        % Compute dual variable.
        p = LHS\RHS;
        disp(norm(LHS*p-RHS,2));
        
        % Compute primal variables.
        u = (1/(lambda+theta))*(lambda*f+theta*ubar-(A')*p);
        c = (1/(mu+theta))*(mu*g + theta*cbar - (B')*p);
        
        % Compute energy.
        eArr((k-1)*inner + j) = EneR(u,c,f,lambda);
        
    end
end
end

function e = EneR(u,c,f,lambda)
e = norm(u-f,2)^2 + 0.5*lambda*norm(1-c,2)^2;
end
