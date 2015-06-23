function [u, c] = FindMask(f, lambda, varargin)

% Copyright 2013, 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

%% Check Input and Output

narginchk(2, 22);
nargoutchk(0, 8);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('f',      @(x) validateattributes(x, {'numeric'}, {'nonempty','finite'},                        mfilename, 'f',      1));
parser.addRequired('lambda', @(x) validateattributes(x, {'numeric'}, {'scalar','nonempty','finite','nonnegative'}, mfilename, 'lambda', 2));

parser.addParameter('mu',       1.25,          @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'},            mfilename, 'mu'));
parser.addParameter('e',        1e-4,          @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'},            mfilename, 'e'));
parser.addParameter('maxit',    1,             @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative', 'integer'}, mfilename, 'maxit'));
parser.addParameter('cInit',    ones(size(f)), @(x) validateattributes(x, {'numeric'}, {'nonempty','finite'},                                      mfilename, 'cInit'));
parser.addParameter('logging',  true,          @(x) validateattributes(x, {'logical'}, {'scalar'},                                                 mfilename, 'logging'));
parser.addParameter('plot',     false,         @(x) validateattributes(x, {'logical'}, {'scalar'},                                                 mfilename, 'plot'));
parser.addParameter('verbose',  true,          @(x) validateattributes(x, {'logical'}, {'scalar'},                                                 mfilename, 'verbose'));
parser.addParameter('kkt',      false,         @(x) validateattributes(x, {'logical'}, {'scalar'},                                                 mfilename, 'kkt'));
parser.addParameter('operator', 'laplace',     @(x) strcmpi(x, validatestring( x, {'laplace', 'biharmonic'},                                       mfilename, 'operator')));
parser.addParameter('PockIt',   25000,         @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'},            mfilename, 'PockIt'));
parser.addParameter('PockTol',  1e-12,         @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonempty', 'finite', 'nonnegative'},            mfilename, 'PockTol'));

parser.parse( f, lambda, varargin{:});
opts = parser.Results;

%% Initialisation

[ro, co] = size(f);
if isvector(f)
    is1d = true;
else
    is1d = false;
end
D       = LaplaceM(ro,co);
if strcmpi(opts.operator,'biharmonic')
    D = -D*D;
end
N       = ro*co;
I       = speye(N, N);
c       = inf(ro,co);
i       = 1;
cbar    = opts.cInit;

%% Run Code.

if opts.plot || opts.logging
    FIG      = randi([8192 65535],1);
end
if opts.verbose || opts.plot
    ENERGY   = inf(1,opts.maxit);
    ERROR    = inf(1,opts.maxit);
    ENERGYT  = inf(1,opts.maxit);
    ERRORT   = inf(1,opts.maxit);
    DENSITY  = inf(3,opts.maxit);
    TIME     = 0;
end

while i <= opts.maxit
    
    if ((norm(c(:)-cbar(:), 2) < 1e-15) && (i > 1))
        break;
    end
    
    %% - Iterate -------------------------------------------------------- %%
    
    % - Set up current position for Taylor expansion. -------------------- %
    
    % Note that in any case, the pairs (ubar, cbar) and (u, c) will always
    % be feasible solutions of the initial PDE.
    if i == 1
        %% - Start with a full mask. ------------------------------------ %%
        
        M    = spdiags(ToVec(cbar), 0, N, N) - (I - spdiags(ToVec(cbar), 0, N, N))*D;
        ubar = ToIm(M\ToVec(ToIm(cbar,ro,co).*f),ro,co);
        
    else
        %% - Take mask and solution from previous iteration. ------------ %%
        
        cbar = c;
        ubar = u;
        
    end
    
    % - Compute operators occuring in the optimisation -------------------- %
    
    % T(u,c) = c(u-f) - (1-c)*D*u
    % T(u,c) = T(ubar,cbar) + D_uT(ubar,cbar)(u-ubar) + D_cT(ubar,cbar)(c-cbar)
    
    % T(ubar,cbar) = 0
    % A = D_uT(ubar,cbar) = cbar - (1-cbar)*D
    % B = D_cT(ubar,cbar) = ubar-f+D*ubar
    % g = D_uT(ubar,cbar)ubar + D_cT(ubar,cbar)*cbar = cbar*(I+D)*ubar
    
    % Note that A is the inpainting matrix.
    % A = C - (I-C)*D;
    A = spdiags(ToVec(cbar), 0, N, N) - (I - spdiags(ToVec(cbar), 0, N, N))*D;
    
    % B = u - f + D*u;
    bb = ToVec(ubar-f) + smvp(D,ToVec(ubar));
    
    % g = c*(I+D)*u
    g = ToVec(cbar) .* smvp(( I + D ),ToVec(ubar));
    
    % - Solve optimisation problem to get new mask ----------------------- %
    
    tic();
    [utemp, c, j, du, dc] = PockChambolleMex( ToVec(f), ToVec(cbar), A, A', bb, g, opts.e, opts.mu, opts.lambda, opts.PockIt, opts.PockTol);
    
    if opts.kkt
        %% - Check KKT conditions for linearized problem. ---------------- %
        
        r1 = norm(A*utemp+bb.*c-g,2)^2;
        if r1 > 1e-10
            fprintf(2, 'LINEARIZED PROBLEM:\tResidual of constraint equation is %12.10f\n', r1);
        end
        
        deltal = (A')\(utemp-ToVec(f));
        r2 = norm((A')*deltal-(utemp-ToVec(f)),2)^2;
        if r2 > 1e-10
            fprintf(2, 'LINEARIZED PROBLEM:\tResidual of adjoint equation is %12.10f\n', r2);
        end
        
        subgl = -1.0/opts.lambda * ( -bb.*deltal + opts.e*c + opts.mu*(c-ToVec(cbar)));
        if ~all(abs(subgl(:))<=1)
            fprintf(2, 'LINEARIZED PROBLEM:\tImpossible subgradient detected. Min: %12.10f -- Max: %12.10f\n', min(subgl(:)), max(subgl(:)));
        end
        
    end
    
    %% - Compute solution corresponding to new mask. --------------------- %
    
    if norm(c(:)) < 100*eps
        
        % If c is 0, no need to compute a solution u. It must be 0.
        u = zeros(size(c));
        uT = u;
        
    else
        % Compute solution.
        M = spdiags(c, 0, N, N) - (I - spdiags(c, 0, N, N))*D;
        u = M\ToVec(ToIm(c,ro,co).*f);
        
        if opts.verbose
            fprintf(2,'\n-----------------------------------------------------------------\n');
            fprintf(2, 'Iteration:\t\t%d.\n', i-1);
            fprintf(2, 'Distance betwwen u (Chambolle) and f:\t%g.\n', norm(utemp(:)-f(:)));
            fprintf(2, 'Distance betwwen u (PDE solut) and f:\t%g.\n', norm(u(:)-f(:)));
            fprintf(2,'\n-----------------------------------------------------------------\n');
        end
        
        if opts.kkt
            %% - Check KKT conditions for original problem. ------------------ %
            
            r1 = norm(M*u-ToVec(ToIm(c,ro,co).*f),2)^2;
            if r1 > 1e-10
                fprintf(2, 'ORIGINAL PROBLEM:\tResidual of constraint equation is %12.10f\n', r1);
            end
            
            deltao = (M')\(u-ToVec(f));
            r2 = norm((M')*deltao-(u-ToVec(f)),2)^2;
            if r2 > 1e-10
                fprintf(2, 'ORIGINAL PROBLEM:\tResidual of adjoint equation is %12.10f\n', r2);
            end
            
            TEMPM = spdiags(u-ToVec(f)+D*u, 0, N, N);
            subgo = -1.0/opts.lambda * ( (TEMPM')*deltao + opts.e*c );
            if ~all(abs(subgo(:))<=1)
                fprintf(2, 'ORIGINAL PROBLEM:\tImpossible subgradient detected. Min: %12.10f -- Max: %12.10f\n', min(subgo(:)), max(subgo(:)));
            end
            
        end
        
        cT = c;
        cT(abs(c)<=0.01) = 0;
        cT(abs(c)>0.01)  = 1;
        
        MT = spdiags(cT, 0, N, N) - (I - spdiags(cT, 0, N, N))*D;
        uT = MT\ToVec(ToIm(cT,ro,co).*f);
        
    end
    t = toc();
    
    % Increase iteration count.
    i = i+1;
    
    u  = ToIm(u,ro,co);
    c  = ToIm(c,ro,co);
    uT = ToIm(uT,ro,co);
    
    if opts.verbose || opts.logging
        
        TIME = TIME + t;
        
        ENERGY(i-1) = 0.5 * norm(u(:)-f(:), 2)^2 + lambda * norm(c(:), 1) + opts.e*norm(c(:), 2)^2;
        ENERGYT(i-1) = 0.5 * norm(uT(:)-f(:), 2)^2 + lambda * norm(cT(:), 1) + opts.e*norm(cT(:), 2)^2;
        
        ERROR(i-1) = norm(255*(u(:)-f(:)),2)^2/numel(u);
        ERRORT(i-1) = norm(255*(uT(:)-f(:)),2)^2/numel(uT);
        
        DENSITY(1,i-1) = 100*sum(abs(c(:))>0)/numel(c);
        DENSITY(2,i-1) = 100*sum(abs(c(:))>0.01)/numel(c);
        DENSITY(3,i-1) = norm(c(:),1)/numel(c);
        
    end
    
    if opts.verbose
        fprintf(1,'\n-----------------------------------------------------------------\n');
        fprintf(1, 'Iteration:\t\t%d.\n', i-1);
        fprintf(1, 'Time:\t\t\t%g (%g Total).\n', t, TIME);
        fprintf(1, 'Error:\t\t\t%g, %g.\n', ERROR(i-1), ERRORT(i-1));
        fprintf(1, 'Energy:\t\t\t%g, %g.\n', ENERGY(i-1), ENERGYT(i-1));
        fprintf(1, 'Density:\t\t%d / %d = %g percent.\n', sum(abs(c(:))>0.001), numel(c), 100*sum(abs(c(:))>0.001)/numel(c));
        fprintf(1, 'Chambolle iterations:\t\t%d\n', j);
        fprintf(1, 'Distance between Chambolle its.:\t%g, %g\n',du,dc);
        fprintf(1, 'Duality gap in Chambolle alg.:\t%g\n',norm(A*utemp+bb.*ToVec(c)-g,2));
        fprintf(1, 'Distance betwwen old an new c:\t%g.\n', norm(c(:)-cbar(:)));
        fprintf(1, 'Distance betwwen old an new u:\t%g.\n', norm(u(:)-ubar(:)));
        fprintf(1,'\n-----------------------------------------------------------------\n');
    end
    
    if ((mod(i-1,2) == 0) && (i >= 1)) && opts.plot
        figure(FIG);
        
        subplot(3,5,1); %(1,1)
        if is1d
            plot(1:numel(f),f(:),'-k',1:numel(f),c(:),'*b');
        else
            subimage(c);
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({'Mask',['Density = ' num2str(100*sum(sum(abs(c)>0))/numel(c)) '%'], ['Min/Max: ', num2str(min(c(:))) '/' num2str(max(c(:)))]});
        
        subplot(3,5,2); %(1,2)
        if is1d
            plot(f(:));
        else
            subimage(f);
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({'Image', ['Min/Max: ', num2str(min(f(:))) '/' num2str(max(f(:)))]});
        
        subplot(3,5,3); %(1,3)
        if is1d
            plot(u(:));
        else
            subimage(u);
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({['Solution - lambda = ' num2str(lambda)],['Energy = ' num2str(ENERGY(i-1)) ' - Error ' num2str(ERROR(i-1))],['Min/Max: ', num2str(min(u(:))) '/' num2str(max(u(:)))]});
        
        subplot(3,5,4); %(1,4)
        if is1d
            plot(abs(u(:)-f(:)));
        else
            subimage(ImageNormalise(abs(u-f)));
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({'Absolute difference solution',['Min: ' num2str(min(abs(u(:)-f(:))))],['Max: ' num2str(max(abs(u(:)-f(:))))]});
        
        if opts.kkt
            subplot(3,5,5); %(1,5)
            if is1d
                plot(deltao(:));
            else
                subimage(ImageNormalise(ToIm(deltao,ro,co)));
                set(gca(),'XTick',[],'YTick',[]);
            end
            title({'Adjoint variable',['Min: ' num2str(min(deltao(:)))],['Max: ' num2str(max(deltao(:)))]});
        end
        
        subplot(3,5,6); %(2,1)
        if is1d
            plot(1:numel(f),f(:),'-k',1:numel(f),cT(:),'*b');
        else
            subimage(ToIm(cT,ro,co));
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({'Mask - Thresholded',['Density = ' num2str(100*sum(sum(abs(cT)>0.001))/numel(cT)) '%'], ['Min/Max: ', num2str(min(cT(:))) '/' num2str(max(cT(:)))]});
        
        subplot(3,5,7); %(2,2)
        if is1d
            plot(f(:));
        else
            subimage(f);
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({'Image', ['Min/Max: ', num2str(min(f(:))) '/' num2str(max(f(:)))]});
        
        subplot(3,5,8); %(2,3)
        if is1d
            plot(uT(:));
        else
            subimage(uT);
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({['Solution - Thresholded - lambda = ' num2str(lambda)],['Energy = ' num2str(ENERGYT(i-1)) ' - Error ' num2str(ERRORT(i-1))],['Min/Max: ', num2str(min(uT(:))) '/' num2str(max(uT(:)))]});
        
        subplot(3,5,9); %(2,4)
        if is1d
            plot(abs(uT(:)-f(:)));
        else
            subimage(ImageNormalise(abs(uT-f)));
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({'Absolute difference solution (thresh.)',['Min: ' num2str(min(abs(uT(:)-f(:))))],['Max: ' num2str(max(abs(uT(:)-f(:))))]});
        
        if opts.kkt
            subplot(3,5,10); %(2,5)
            if is1d
                plot(subgo(:));
            else
                subimage(ImageNormalise(ToIm(subgo,ro,co)));
                set(gca(),'XTick',[],'YTick',[]);
            end
            title({'Subgradient variable',['Min: ' num2str(min(subgo(:)))],['Max: ' num2str(max(subgo(:)))]});
        end
        
        subplot(3,5,11); %(3,1)
        if is1d
            plot(abs(c(:)-cT(:)))
        else
            subimage(ImageNormalise(abs(c-ToIm(cT,ro,co))));
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({'Absolute difference masks',['Min: ' num2str(min(abs(c(:)-cT(:))))],['Max: ' num2str(max(abs(c(:)-cT(:))))]});
        
        subplot(3,5,12); %(3,2)
        plot(1:(i-1), ENERGY(1:(i-1)), 1:(i-1), ENERGYT(1:(i-1)) );
        title({['Iteration: ' num2str(i-1)],['Energy = ' num2str(ENERGY(i-1))],['Energy (thresh.) = ' num2str(ENERGYT(i-1))]});
        legend('Optimal Control', 'Thresholded.','Location','Best');
        
        subplot(3,5,13); %(3,3)
        plot(1:(i-1), ERROR(1:(i-1)), 1:(i-1), ERRORT(1:(i-1)));
        title({['Iteration: ' num2str(i-1)],['MSE = ' num2str(ERROR(i-1))],['MSE (thresh.) = ' num2str(ERRORT(i-1))]});
        legend('Optimal Control', 'Thresholded.','Location','Best');
        
        subplot(3,5,14); %(3,4)
        if is1d
            plot(c(:)-cbar(:))
        else
            subimage(ImageNormalise(c-cbar));
            set(gca(),'XTick',[],'YTick',[]);
        end
        title({'Difference between previous and actual mask', ['Min: ' num2str(min(abs(c(:)-cbar(:))))],['Max: ' num2str(max(abs(c(:)-cbar(:))))]});
        
        subplot(3,5,15); %(3,5)
        plot(1:(i-1), DENSITY(1,1:(i-1))/100, 1:(i-1), DENSITY(2,1:(i-1))/100, 1:(i-1), DENSITY(3,1:(i-1)));
        axis([0 i 0 1.1])
        title({['Iteration: ' num2str(i-1)],['DENSITY (>0) = ' num2str(DENSITY(1,(i-1))) '%'],['DENSITY (>0.01) = ' num2str(DENSITY(2,(i-1))) '%'],['Aver. L1 Norm of c = ' num2str(DENSITY(3,(i-1)))]});
        legend('|c|>0', '|c|>0.01', 'Aver. L1 Norm','Location','Best');
        % Flush event queue and update figure window.
        drawnow expose; pause(.1);
    end
    
    if (mod(i-1,10)==0 && i-1 > 2) && opts.logging
        mu = opts.mu;
        epsi = opts.e;
        its = i-1;
        save(['~/LOGS/' num2str(FIG) '-' CreateTimeStamp('LOG') '__' num2str(lambda) '__' num2str(opts.mu) '__' num2str(its) '.mat'], 'u', 'c', 'ENERGY', 'ERROR', 'ENERGYT', 'ERRORT', 'lambda', 'TIME', 'ERROR', 'DENSITY', 'its', 'mu', 'epsi', '-v7.3');
    end
    
end
end

function vec = ToVec(im)
t = im';
vec = t(:);
end

function im = ToIm(vec,r,c)
im = reshape(vec,c,r)';
end
