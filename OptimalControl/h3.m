function res = h3(p, A, B, f, ubar, cbar, g, lambda, theta, epsi)

temp1 = g - A*(theta*ubar+f)/(1+theta) - theta*(B.*cbar)/(epsi+theta);
temp2 = sum(p(:).*temp1(:));

res = temp2 + ...
    1/(2*(1+theta)) * norm((A')*p,2)^2 + ...
    1/(2*(epsi+theta)) * norm(B(:).*p(:),2)^2 - ...
    sum(kappa(p, B, cbar, lambda, epsi, theta));
end
