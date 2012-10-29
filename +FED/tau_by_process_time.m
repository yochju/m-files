function out = tau_by_process_time(T, M, tau_max, reordering)
out = FED.tau_by_cycle_time(T/M, tau_max, reordering);
end
