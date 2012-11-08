function [g u] = IterativeGVO(f,c,Its)
u = SolvePde(f,c);
g = f;
K = find(c);
for k = 1:Its
    for i = K(randperm(numel(K)))'
        ei = zeros(size(u));
        ei(i) = 1;
        ui = SolvePde(ei,c);
        a = (ui(:)'*(f(:)-u(:)))/(ui(:)'*ui(:));
        uold = u; % used for while loop.
        u = u + a*ui;
        g(i) = g(i) + a;
    end
end
end
