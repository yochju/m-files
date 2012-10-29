function out = tau_by_cycle_time(t, tau_max, reordering)
%n = fix(ceil(sqrt(3.0*t/tau_max+0.25)-0.5-1.0e-8)+0.5);

% This is not exactly the same as in the code, but according to the theory it
% should be correct. The difference with the original code lies in those numbers
% where the solution is exact (although it's not systematic).
n = ceil(sqrt(3*t./tau_max + 0.25)-0.5);
scale = 3.0*t/(tau_max*(n*(n+1)));
out = tau_internal(n, scale, tau_max, reordering);
end
%  [ (0.0:0.1:8.4) ; round(sqrt(3.0*(0.0:0.1:8.4)/tau_max+0.25)) ]
