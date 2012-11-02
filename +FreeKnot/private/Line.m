function out = Line(z,x,y)
out = nan(size(z));
% If z == x1 or z== x2, then we would have a division by 0. Nevertheless, we
% know that the line must evaluate to the function value in that case.
out(abs(z-x(1)) <= eps(x(1))) = y(1);
out(abs(z-x(2)) <= eps(x(2))) = y(2);
% Determine all the remaining positions and function values.
p = logical((abs(z-x(1))>eps(x(1))).*(abs(z-x(2))>eps(x(2))));
t = z(p);
out(p) = (y(2)-y(1))./(x(2)-x(1)).*(t-x(1)) + y(1);
end
