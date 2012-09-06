%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script runs the optimal control algorithms for single scale and
% multiscale models in batch mode. The goal is to collect data for benchamrking
% different parameter choices as well as potential quality improvements obtained
% by multi scale formulations.
%
% The following test are being performed:
%
% 1. Stability of the model. Since the initialisation is random, we could run
%    into different local minima at each run. Does this happen or is the
%    penalisation tolerant enough to circumvent this issue?
%
% 2. Influence on the multiscale formulation.
%    2.1 Sanity check. For 1 scale the multiscale and single scale results
%        should not differ.
%    2.2 Does it really yield an improvement. If so, how much?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% - Clean up the work space and make some sanity checks. ----------------------

% Clear workspace to avoid clashes with variables coming from unknown origins.
clear variables;

% We save the data in the folder benchmark.
DataFolder = [ pwd '/' 'benchmark' ];

% The following folders contain the data of the respective experiment.
Exp1Folder = [ DataFolder '/' 'experiment1' ];
Exp2Folder = [ DataFolder '/' 'experiment2' ];

% Check that the folder for saving the data exists. If not create it.
if ~isdir(DataFolder)
    
    [status,message,messageid] = mkdir(DataFolder);
    if status == 0
        error(messageid,message);
    end
end

% Check that the folder for saving experiment 1 exists. If not create it.
if ~isdir(Exp1Folder)
    [status,message,messageid] = mkdir(Exp1Folder);
    if status == 0
        error(messageid,message);
    end
end

% Check that the folder for saving experiment 2 exists. If not create it.
if ~isdir(Exp2Folder)
    [status,message,messageid] = mkdir(Exp2Folder);
    if status == 0
        error(messageid,message);
    end
end

%% - Set up the parameters. ----------------------------------------------------

% Length of the considered signal.
% Anything around 100 samples should be fine here. The framework can handle
% larger values without too much problems but it will also increase the
% computation time.
N = 128;

% Normalize the Signal.
% Basically this is not really necessary. Hoewever, the mask will (for whatever
% reason) live in the range [0,1] (we do not enforce this!). Having all the data
% in the same range greatly simplifies the selection of the regularisation
% parameter. Furthermore, the numerical stability of the algorithm should also
% benefit from equilibrated data.
I = MakeSignal('Piece-Polynomial',N);
I = I - min(I(:));
I = I/max(I(:));

% Stop if maximal change is below this threshold. This is just a counter measure
% to prevent excessive iteration when we have reached the fix point. Something
% like 0.001 seems to be a good value.
tolK = 0.001;
tolI = 0.001;

% Maximal number of iterations. itK is the number of outer iterations for the
% outer loop which is responsible for increasing the penalisation of the
% proximal terms. itI represents the number of inner iterations, e.g. the number
% of alternating minimisation steps. Increasing itI is less critical than
% increasing itK. Something in the range of 20-30 iterations should be more than
% enough for signals of up to 256 samples.
itK = 25;
itI = 25;

% Regularization weight in the energy. Be gentle to this parameter. The
% algorithm reacts sometimes quite violently to changes. For values close to 0,
% the reconstruction should be almost perfect and the mask should contain many
% 1s. For large values (>> 1), the mask should be almost empty (e.g. 0) and the
% reconstruction should be 0 almost everywhere. Note that the algorithm cannot
% reconstruct the constant signal with the average gray value because in the
% extreme case we end up with Neumann boundary conditions on the outer
% boundaries and no Dirichlet conditions at all that could tell us anything
% about the underlying signal.
lambda = 0.1;

% Initial penalisation weight for the PDE. It will be increased on every
% iteration on itK. Setting this parameter larger than those for the proximal
% terms on the solution and the mask seems to be reasonable. Also, the initial
% value shouldn't be too large, otherwise we restrict the movement of the points
% too much and end up in bad local minima.
theta = 10e0;

% Initial penalisation weight for the proximal term. These two variables
% penalise the proximal terms that prevent new iterates from being too far away
% from the previous one. It is probably a good idea to not set these too large.
uStep = 0.01;
cStep = 0.01;

% scaling refers to the downsampling factor for the multiscale approach.
% minSample is the minimal number of samples that we will consider.
scaling = 0.75;
minSample = round(N/8);

%% - Test 1 --------------------------------------------------------------------

% NumTest specifies the number of times the same test is going to be run. For
% each run, we will save the results in the cell array Experiment1. Each entry
% of this cell array will be a structure with the fields corresponding to the
% returned results from the considered run. E.g
% Experiment1{3} = struct with the results from test 3.
% Experiment1{3}.u = corresponding reconstruction.
% Experiment1{3}.c = corresponding mask.
NumTest = 10;

% Run the experiment for the single scale setting.

Experiment1 = cell(NumTest,1);

% File where the data will be saved to.
BackupFile = [Exp1Folder '/' datestr(now,'yyyy-mm-dd_HH:MM:SS') '-single.mat'];

fprintf(1, 'Test 1 (single scale) started on %s.\n', ...
    datestr(now,'yyyy-mm-dd HH:MM:SS'));
for n = 1:NumTest
    fprintf(1,'Run %d out of %d\n',n,NumTest);
    
    % Run the experiment and measure the runtime.
    tic();
    [u c NumIter EnerVal ResiVal IncPEN] = OptimalControlPenalize( ...
        I(:), lambda, theta, itK, itI, tolK, tolI, uStep, cStep);
    tim = toc();
    
    % Compute the final energy and residual.
    Ener = Energy(u,c,I(:),lambda);
    Resi = Residual(u,c,I(:));
    
    % Save the data.
    Experiment1{n}.Reconst = u(:);       % Final Reconstruction
    Experiment1{n}.Mask    = c(:);       % Final Mask
    Experiment1{n}.NumIter = NumIter;    % Number of iterations
    Experiment1{n}.EnerVal = EnerVal(:); % Evolution of the energy
    Experiment1{n}.ResiVal = ResiVal(:); % Evolution of the residual
    Experiment1{n}.IncPena = IncPEN(:);  % Iterates when penalisation changed
    Experiment1{n}.Runtime = tim;        % Running time.
    Experiment1{n}.FinEner = Ener;       % Final energy.
    Experiment1{n}.FinResi = Resi;       % Final residual.
    
    save(BackupFile,'Experiment1');
end
fprintf(1, 'Test 1 (single scale) finished on %s.\n', ...
    datestr(now,'yyyy-mm-dd HH:MM:SS'));

% Save parameters used for the experiments.
save(BackupFile, 'N', 'I', 'lambda', 'theta', 'itK', 'itI', 'tolK', 'tolI', ...
    'uStep', 'cStep', '-append');

fprintf(1, 'Data has been saved to %s\n',BackupFile);

% Run the experiment for the multi scale setting.

Experiment1 = cell(NumTest,1);

% File where the data will be saved to.
BackupFile = [Exp1Folder '/' datestr(now,'yyyy-mm-dd_HH:MM:SS') '-multi.mat'];

fprintf(1,'Test 1 (multi scale) started on %s.\n', ...
    datestr(now,'yyyy-mm-dd HH:MM:SS'));
for n = 1:NumTest
    fprintf(1,'Run %d out of %d\n',n,NumTest);
    
    % Run the experiment and measure the runtime.
    tic();
    [u c NumIter EnerVal ResiVal IncPEN] = MultiScaleOptimalControlPenalize( ...
        I(:), lambda, theta, itK, itI, tolK, tolI, uStep, cStep, ...
        scaling, minSample);
    tim = toc();
    
    % Compute the final energy and residual.
    Ener = Energy(u,c,I(:),lambda);
    Resi = Residual(u,c,I(:));
    
    % Save the data.
    Experiment1{n}.Reconst = u(:);       % Final Reconstruction
    Experiment1{n}.Mask    = c(:);       % Final Mask
    Experiment1{n}.NumIter = NumIter;    % Number of iterations
    Experiment1{n}.EnerVal = EnerVal(:); % Evolution of the energy
    Experiment1{n}.ResiVal = ResiVal(:); % Evolution of the residual
    Experiment1{n}.IncPena = IncPEN(:);  % Iterates when penalisation changed
    Experiment1{n}.Runtime = tim;        % Running time.
    Experiment1{n}.FinEner = Ener;       % Final energy.
    Experiment1{n}.FinResi = Resi;       % Final residual.
    
    save(BackupFile, 'Experiment1');
end
fprintf(1, 'Test 1 (multi scale) finished on %s.\n', ...
    datestr(now,'yyyy-mm-dd HH:MM:SS'));

% Save parameters used for the experiments.
save(BackupFile, 'N', 'I', 'lambda', 'theta', 'itK', 'itI', 'tolK', 'tolI', ...
    'uStep', 'cStep', 'scaling', 'minSample', '-append');

fprintf(1, 'Data has been saved to %s\n', BackupFile);

%% - Test 2 --------------------------------------------------------------------

% lamRange is the set of values for which we test whether the multiscale
% formalism offers any benefit at all. The data structure where the results are
% being save to, is similar to the one for Test 1.

lamRange = 0.001:0.01:0.05;

Experiment2 = cell(length(lamRange),1);

% File where the data will be saved to.
BackupFile = [Exp2Folder '/' datestr(now,'yyyy-mm-dd_HH:MM:SS') '.mat'];

fprintf(1,'Test 2 started on %s.\n', ...
    datestr(now,'yyyy-mm-dd HH:MM:SS'));
for l = lamRange
    [u c NumIter EnerVal ResiVal IncPEN] = OptimalControlPenalize( ...
        I(:), l, theta, itK, itI, tolK, tolI, uStep, cStep);
    
    % Save the data for the single scale case.
    Experiment2{n}.RecoS = u(:);       % Final Reconstruction
    Experiment2{n}.MaskS = c(:);       % Final Mask
    Experiment2{n}.NuItS = NumIter;    % Number of iterations
    Experiment2{n}.EnVaS = EnerVal(:); % Evolution of the energy
    Experiment2{n}.ReVaS = ResiVal(:); % Evolution of the residual
    Experiment2{n}.InPeS = IncPEN(:);  % Iterates when penalisation changed
    Experiment2{n}.FiEnS = Ener;       % Final energy.
    Experiment2{n}.FiReS = Resi;       % Final residual.
    
    [u c NumIter EnerVal ResiVal IncPEN] = MultiScaleOptimalControlPenalize( ...
        I(:), l, theta, itK, itI, tolK, tolI, uStep, cStep, ...
        1, N);
    
    % Save the data for the sanity check.
    Experiment2{n}.RecoS1 = u(:);       % Final Reconstruction
    Experiment2{n}.MaskS1 = c(:);       % Final Mask
    Experiment2{n}.NuItS1 = NumIter;    % Number of iterations
    Experiment2{n}.EnVaS1 = EnerVal(:); % Evolution of the energy
    Experiment2{n}.ReVaS1 = ResiVal(:); % Evolution of the residual
    Experiment2{n}.InPeS1 = IncPEN(:);  % Iterates when penalisation changed
    Experiment2{n}.FiEnS1 = Ener;       % Final energy.
    Experiment2{n}.FiReS1 = Resi;       % Final residual.
    
    [u c NumIter EnerVal ResiVal IncPEN] = MultiScaleOptimalControlPenalize( ...
        I(:), l, theta, itK, itI, tolK, tolI, uStep, cStep, ...
        0.75, minSample);
    
    % Save the data for the 0.75 scaling check.
    Experiment2{n}.RecoS075 = u(:);       % Final Reconstruction
    Experiment2{n}.MaskS075 = c(:);       % Final Mask
    Experiment2{n}.NuItS075 = NumIter;    % Number of iterations
    Experiment2{n}.EnVaS075 = EnerVal(:); % Evolution of the energy
    Experiment2{n}.ReVaS075 = ResiVal(:); % Evolution of the residual
    Experiment2{n}.InPeS075 = IncPEN(:);  % Iterates when penalisation changed
    Experiment2{n}.FiEnS075 = Ener;       % Final energy.
    Experiment2{n}.FiReS075 = Resi;       % Final residual.
    
    [u c NumIter EnerVal ResiVal IncPEN] = MultiScaleOptimalControlPenalize( ...
        I(:), l, theta, itK, itI, tolK, tolI, uStep, cStep, ...
        0.5, minSample);
    
    % Save the data for the 0.50 scaling check.
    Experiment2{n}.RecoS050 = u(:);       % Final Reconstruction
    Experiment2{n}.MaskS050 = c(:);       % Final Mask
    Experiment2{n}.NuItS050 = NumIter;    % Number of iterations
    Experiment2{n}.EnVaS050 = EnerVal(:); % Evolution of the energy
    Experiment2{n}.ReVaS050 = ResiVal(:); % Evolution of the residual
    Experiment2{n}.InPeS050 = IncPEN(:);  % Iterates when penalisation changed
    Experiment2{n}.FiEnS050 = Ener;       % Final energy.
    Experiment2{n}.FiReS050 = Resi;       % Final residual.
    
    [u c NumIter EnerVal ResiVal IncPEN] = MultiScaleOptimalControlPenalize( ...
        I(:), l, theta, itK, itI, tolK, tolI, uStep, cStep, ...
        0.25, minSample);
    
    % Save the data for the 0.25 scaling check.
    Experiment2{n}.RecoS025 = u(:);       % Final Reconstruction
    Experiment2{n}.MaskS025 = c(:);       % Final Mask
    Experiment2{n}.NuItS025 = NumIter;    % Number of iterations
    Experiment2{n}.EnVaS025 = EnerVal(:); % Evolution of the energy
    Experiment2{n}.ReVaS025 = ResiVal(:); % Evolution of the residual
    Experiment2{n}.InPeS025 = IncPEN(:);  % Iterates when penalisation changed
    Experiment2{n}.FiEnS025 = Ener;       % Final energy.
    Experiment2{n}.FiReS025 = Resi;       % Final residual.
    
    save(BackupFile, 'Experiment2');
end
fprintf(1, 'Test 2 finished on %s.\n', ...
    datestr(now,'yyyy-mm-dd HH:MM:SS'));

% Save parameters used for the experiments.
save(BackupFile, 'N', 'I', 'theta', 'itK', 'itI', 'tolK', 'tolI', ...
    'uStep', 'cStep', 'minSample', 'lamRange', '-append');

fprintf(1, 'Data has been saved to %s\n', BackupFile);