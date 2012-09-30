function [ c d ] = ShrinkCoeffs(obj,level,f)
[ c d ] = obj.Decompose();
for i = 1:length(level)
    d{level(i)+1} = f(d{level(i)+1});
end
end