%% Set parameters.
clear all;

% Signal Length
N = 128;

% Signal (normalized)
Sig = MakeSignal('Piece-Polynomial',N);
Sig = Sig - min(Sig(:));
f = Sig/max(Sig(:));

% Mask (in my opinion optimal for the Piece-Polynomial signal)
c = zeros(N,1);
p = [1 6 7 18 19 25 26 50 51 75 76 100 101 116 117 122 123 128];
c(p) = 1;
uE = SolvePde(f,c);

% Regularisation parameters to be tested.
lam = linspace(0.001, 0.3, 128);

%% Compute data.

% Compute the evolution 10 times.
Data = EnergyEvolInReg(f(:), lam);

% Compute Solutiuon corresonding to mask from above.
u = SolvePde(f(:), c(:));

%% Plot data.

% Create figure
figure(100);
clf();

% Create subplot
subplot1 = subplot(2, 1, 1, 'Parent', gcf(), 'FontSize', 12);
box(subplot1,'on');
grid(subplot1,'on');
hold(subplot1,'all');

% Plot Signal, Mask and Reconstruction.
plot( ...
    1:N, f, '-k', ...
    1:N, u, '--b', ...
    p, f(p), 'or', ...
    'LineWidth', 2, 'MarkerSize', 6);

grid on;

legend('Signal', 'Reconstruction', 'Mask points', ...
    'Location','Best');
xlabel('x','FontSize',12);
ylabel('f(x)','FontSize',12);
comparelambda = 0.14135;
title( ...
    sprintf('Considered Signal, mask points and corresponding reconstruction. Energy = %d (lambda = %d)', ...
    Energy(uE(:),c(:),f(:), comparelambda),comparelambda), ...
    'FontWeight', 'demi', 'FontSize', 12);

subplot2 = subplot(2, 1, 2, 'Parent', gcf(), 'FontSize', 12);
box(subplot2,'on');
grid(subplot2,'on');
hold(subplot2,'all');

% Plot Signal, Mask and Reconstruction.
plot( lam, Data, '-k', 'LineWidth', 2, 'MarkerSize', 6);

grid on;

xlabel('\lambda','FontSize',12);
ylabel('Energy','FontSize',12);

title('Evolution of the energy in function of the regularisation.', ...
    'FontWeight', 'demi', 'FontSize', 12);

%% Compute solution to manually chosen optimal lambda.

parameters.MaxOuter = 15;
parameters.MaxInner = 50;
parameters.TolOuter = 0.0001;
parameters.TolInner = 0.0001;
parameters.lambda   = 0.14135;
parameters.penPDE   = 1.1;
parameters.penu     = 1.1;
parameters.penc     = 1.1;
parameters.uStep    = 1.1;
parameters.cStep    = 1.1;
parameters.PDEstep  = 1.1;
parameters.thresh   = -1;
parameters.cInit = 0.5*ones(size(f));
parameters.uInit = f;

[uu cc ItIn ItOut EnVal ReVal IncPe] = OptimalControlPenalize(f(:),parameters);

%% Optimal Solution

parameters1.MaxOuter = 15;
parameters1.MaxInner = 50;
parameters1.TolOuter = 0.0001;
parameters1.TolInner = 0.0001;
parameters1.lambda   = 0.1638;
parameters1.penPDE   = 1.1;
parameters1.penu     = 1.1;
parameters1.penc     = 1.1;
parameters1.uStep    = 1.1;
parameters1.cStep    = 1.1;
parameters1.PDEstep  = 1.1;
parameters1.thresh   = -1;
parameters1.cInit = 0.5*ones(size(f));
parameters1.uInit = f;

[uuu ccc ItIn2 ItOut2 EnVal2 ReVal2 IncPe2] = OptimalControlPenalize(f(:),parameters1);

%% Plot the solution corresponding to the (optimal) lambda.

figure(101);
clf();

subplot(2,1,1);
plot( ...
    1:N, f, '-k', ...
    1:N, uu, '--b', ...
    1:N, cc, 'or', ...
    'LineWidth', 2, 'MarkerSize', 6);
title( ...
    sprintf('Solution corresponding to local minima of lambda = %d, Energy = %d', ...
    parameters.lambda,Energy(uu(:),cc(:),f(:),parameters.lambda)), ...
    'FontWeight', 'demi', 'FontSize', 12);

subplot(2,1,2);
plot( ...
    1:N, f, '-k', ...
    1:N, uuu, '--b', ...
    1:N, ccc, 'or', ...
    'LineWidth', 2, 'MarkerSize', 6);
title( ...
    sprintf('Solution corresponding to hand selected lambda = %d, Energy = %d', ...
    parameters.lambda,Energy(uuu(:),ccc(:),f(:),parameters1.lambda)), ...
    'FontWeight', 'demi', 'FontSize', 12);


