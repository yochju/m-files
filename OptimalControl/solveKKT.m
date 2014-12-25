function [u c] = solveKKT(p, A, B, f, ubar, cbar, g, theta, epsi, lambda)

u = (theta*ubar + f - (A')*p)/(1+theta);

c = sshr((theta*cbar-B.*p)/(epsi+theta), lambda/(epsi+theta));
% c = zeros(size(B(:)));
% pi = abs(B(:))>1e-5;
% temp = g - A*u;
% c(pi) = temp(pi)./B(pi);
end

function y = sshr(x, lambda)
% Softshrinkage.
y = zeros(size(x));
im = (x<-lambda);
ip = (x>lambda);
y(im) = x(im) + lambda;
y(ip) = x(ip) - lambda;
end
