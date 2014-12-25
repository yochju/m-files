function res = nablah3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi)

temp1 = g - A*(theta*ubar+f)/(1+theta) - theta*(B.*cbar)/(epsi+theta);
temp2 = A*(A')*p/(1+theta) + (B.^2).*p/(epsi+theta);

res = temp1 + temp2 - nablakappa(p, B, cbar, lambda, epsi, theta);
end
