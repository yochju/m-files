% Main routine
clear variables;

% Length of the Signal.
N = 128;

% Normalize the Signal.
I = MakeSignal('Piece-Polynomial',N);
I = I - min(I(:));
I = I/max(I(:));

% Stop if maximal change is below this threshold
tolK = 0.001;
tolI = 0.001;

% Maximal number of iterations.
itK = 25;
itI = 25;

% Regularization weight in the Energy.
lambda = 0.1;

% Initial penalization weight for the PDE.
e = 10e0;

% Initial penalization weight for the proximal term.
uStep = 0.01;
cStep = 0.01;

% Solve Problem.
tic();
% Single Level.
% [u c NumIter EnerVal ResiVal IncPEN] = OptimalControlPenalize(I(:),lambda,e,itK,itI,tolK,tolI,uStep,cStep);
% Multi Scale.
[u c NumIter EnerVal ResiVal IncPEN] = MultiScaleOptimalControlPenalize(I(:),lambda,e,itK,itI,tolK,tolI,uStep,cStep,0.95,8);
tim = toc();
Ener = Energy(u,c,I(:),lambda);
Resi = Residual(u,c,I(:));

% Plot Data.
fprintf('\n\n-----------------------------------------------------\n');
fprintf(' Experiment from %s',datestr(now,'yyyy-mmmm-dd (ddd) at HH:MM:SS'));
fprintf('\n-----------------------------------------------------\n');
fprintf('\nSettings\n\n');
fprintf('Signal length..........................');
fprintf('%14d\n',N);
fprintf('Max. Iterations (outer/inner)..........');
fprintf('%6d /  %4d\n',itK,itI);
fprintf('Tolerance (outer/inner)................');
fprintf('%6.3g / %5.3g\n',tolK,tolI);
fprintf('Regularization weight..................');
fprintf('%14.3g\n',lambda);
fprintf('Initial PDE penalization...............');
fprintf('%14.3g\n',e);
fprintf('Initial proximal penalization (u/c)....');
fprintf('%6.2g / %5.2g\n',uStep,cStep);

fprintf('\nResults\n\n');

fprintf('Performed iterations:..................');
fprintf('%14d\n',NumIter);
fprintf('Runtime (seconds)......................');
fprintf('%14.3g\n',tim);
fprintf('Energy.................................');
fprintf('%14.3g\n',Ener);
fprintf('Residual...............................');
fprintf('%14.3g\n\n',Resi);
fprintf('-----------------------------------------------------\n\n');

figure(101);
plot(1:NumIter,EnerVal,'-k',IncPEN,EnerVal(IncPEN),'or', ...
    'LineWidth', 1, ...
    'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'r', ...
    'MarkerSize', 4 );
title('Evolution of the Energy functional');
legend('Energy','Increasing Penalization');
xlabel('Iteration');
ylabel('Energy Value');

figure(102);
plot(1:NumIter,ResiVal,'-k',IncPEN,ResiVal(IncPEN),'or', ...
    'LineWidth', 1, ...
    'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'r', ...
    'MarkerSize', 4 );
title('Evolution of the Residual of the PDE');
legend('Residual','Increasing Penalization');
xlabel('Iteration');
ylabel('Residual Value');

figure(103);
plot( ...
    1:length(I(:)), I, '-k', ...
    1:length(I(:)), u, '--r', ...
    1:length(I(:)), c, 'ob', ...
    'LineWidth', 1, ...
    'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'b', ...
    'MarkerSize', 4 ...
    );
title('Results from the optimization strategy');
legend('Signal','Reconstruction','Mask');
xlabel('Position');
ylabel('Value');