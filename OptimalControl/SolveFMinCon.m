function TestAllQuadratic()
N = 64;
f = Normalise(MakeSignal('Piece-Polynomial',N),1.0);
lambda = 0.125;

Cost = @(x) L1Energy(x,f,lambda);
nlcon = @(x) nonlincon(x,f);

x0 = [f(:) ; 0.5*ones(N,1)];

Ain = [];
bin = [];
Aeq = [];
beq = [];
lb = -Inf(2*N,1);
ub = Inf(2*N,1);

options = optimset( ...
    'Algorithm', 'interior-point', ...
    'Diagnostics', 'on', ...
    'Display', 'iter-detailed', ...
    'FinDiffType', 'central', ...
    'FunValCheck', 'on', ...
    'MaxFunEvals', 75000, ...
    'MaxIter', 1000 ...
    );

[x fval exitflag] = fmincon(Cost,x0,Ain,bin,Aeq,beq,lb,ub,nlcon,options);
figure();
plot(1:N,f,'-r',1:N,x(1:N),'-k',1:N,x((N+1):end),'or');
disp([fval exitflag]);
end

function [c ceq] = nonlincon(x,f)
N = numel(f);
u = x(1:N);
m = x((N+1):end);
c = [];
ceq = EvalPde(f(:),u(:),m(:));
end

function out = L1Energy(x,f,lambda)
N = numel(f);
u = x(1:N);
c = x((N+1):end);
out = 0.5*norm(u(:)-f(:),2)^2 + lambda*norm(c(:),1);
end

function out = L2Energy(x,f,lambda)
N = numel(f);
u = x(1:N);
c = x((N+1):end);
out = 0.5*norm(u(:)-f(:),2)^2 + lambda/2*norm(c(:),2)^2;
end
