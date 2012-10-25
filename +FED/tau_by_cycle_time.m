function out = tau_by_cycle_time(t, tau_max, reordering)
n = ceil(sqrtf(3.0*t/tau_max+0.25)-0.5-1.0e-8)+0.5;
scale = 3.0*t/(tau_max*(n*(n+1)));
out = tau_internal(n, scale, tau_max, reordering);
end
