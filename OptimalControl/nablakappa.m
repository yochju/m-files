function k = nablakappa(p, B, cbar, lambda, epsi, theta)
k = zeros(size(p));
t = B(:).*p(:);

ip = (t> lambda+theta*cbar(:));
im = (t<-lambda+theta*cbar(:));
ii = (t<=lambda+theta*cbar(:)) & (t>=-lambda+theta*cbar(:));

k(ip) = lambda/(epsi+theta)*B(ip);
k(im) =-lambda/(epsi+theta)*B(im);
k(ii) = ((B(ii).^2).*p(ii))/(epsi+theta) - theta*(B(ii).*cbar(ii))/(epsi+theta);
end
