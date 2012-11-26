function out = EigenValuesSym2x2(M)
%% Returns the eigenvalues of a symmetric 2 times 2 matrix.

a = M(1,1);
b = M(2,1);
c = M(2,2);

out = (a+c)/2 + sqrt(4*b^2+(a-c)^2)*[-1;1]; 
end
