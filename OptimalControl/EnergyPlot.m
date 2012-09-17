N = 128;

Sig = MakeSignal('Piece-Polynomial',N);
Sig = Sig - min(Sig(:));
f = Sig/max(Sig(:));

c = zeros(N,1);
p = [1 6 7 18 19 25 26 50 51 75 76 100 101 116 117 122 123 128];
c(p) = 1;

lam = linspace(0.001, 0.5, 25);

Data = vertcat( ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam), ...
    EnergyEvolInReg(f(:), lam) ...
    );

En = mean( Data );
EnSTD = std(Data);

u = SolvePde(f(:),c(:));

% Create figure
figure(100);
    
% Create subplot
subplot1 = subplot(2, 1, 1, 'Parent', gcf(), 'FontSize', 12);
box(subplot1,'on');
grid(subplot1,'on');
hold(subplot1,'all');

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
title('Considered Signal, mask points and corresponding reconstruction.', ...
    'FontWeight', 'demi', 'FontSize', 12);

subplot2 = subplot(2, 1, 2,'FontSize',12);
box(subplot2,'on');
grid(subplot2,'on');
hold(subplot2,'all');

plot( ...
    lam, En , '-k', 'LineWidth', 2 ...
    );

grid on;

legend('Energy', 'Location', 'Best');
xlabel('\lambda','FontSize', 12);
ylabel('Energy Value','FontSize', 12);
title('Energy of the optimal control formulation in function of the regularisation parameter', ...
        'FontWeight', 'demi', ...
        'FontSize', 12);
    
errorbar(lam,En,EnSTD,'xr');
