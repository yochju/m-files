function out = ApproxLinSpline(x,knots,f)
a = knots(1);
b = knots(end);
xi1 = 0.75*knots(1:end-1) + 0.25*knots(2:end);
xi2 = 0.25*knots(1:end-1) + 0.75*knots(2:end);
xi  = [xi1(:) xi2(:)];
fxi = f(xi);
out = nan(size(x));
for i = 1:(numel(knots)-1)
    p = and(x>=knots(i), x<=knots(i+1));
    out(p)=Line(x(p),xi(i,:),fxi(i,:));
end
end

