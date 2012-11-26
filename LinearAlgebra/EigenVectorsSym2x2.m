function out = EigenVectorsSym2x2(M)
%% Returns the normalised eigenvectors of a symmetric 2 times 2 matrix.

a = M(1,1);
b = M(2,1);
c = M(2,2);

v1 = [ a-c-sqrt(4*b^2+(a-c)^2)/(2*b) ; 1 ];
v2 = [ a-c+sqrt(4*b^2+(a-c)^2)/(2*b) ; 1 ];
out = [ v1/norm(v1) v2/norm(v2) ];
end
