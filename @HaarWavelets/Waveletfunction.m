function y = Waveletfunction(x)
y = (x>=0).*(x<0.5) - (x>=0.5).*(x<=1);
end