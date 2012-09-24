function out = OptimizeGrayValue(c,f)
%% Optimize data at interpolation sites for better reconstruction.
M = PdeM(c);
C = Mask(c);
[out, flag, relres, iter] = lsqr( ...
    M\C, f, ...
    1e-5, 512, ...
    speye(size(M)), speye(size(M)), c.*f );

if flag ~= 0
    warning('GVO:stop', 'GVO stopped with flag %g, rel. res. %g at it. %g', ...
        flag, relres, iter );
end
end
