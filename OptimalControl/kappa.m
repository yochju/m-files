function k = kappa(p, B, cbar, lambda, epsi, theta)
k = zeros(size(p));
t = B(:).*p(:);

ip = (t> lambda+theta*cbar(:));
im = (t<-lambda+theta*cbar(:));
ii = (~ip)&(~im);

k(ip) = lambda/(epsi+theta)*t(ip) - (lambda^2+2*lambda*theta*cbar(ip))/(2*(epsi+theta));
k(im) =-lambda/(epsi+theta)*t(im) - (lambda^2-2*lambda*theta*cbar(im))/(2*(epsi+theta));
k(ii) = (t(ii) - theta*cbar(ii)).^2/(2*(epsi+theta));
end
