function [ c d ] = Decompose(obj)
c = cell(1,obj.max_level);
d = cell(1,obj.max_level);
for i=1:obj.max_level
    [ct dt] = obj.Transform(i-1);
    c{i} = ct;
    d{i} = dt;
end
end