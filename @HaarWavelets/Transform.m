function [ c d ] = Transform(obj,level)
n = obj.NumWavelets(level);
c = HaarWavelets.Scalingbasis(obj.max_level-level,0,obj.positions)*(obj.signal');
d = zeros(1,n);
for i = 1:n
    d(i) = HaarWavelets.Waveletbasis(obj.max_level-level,i-1,obj.positions)*(obj.signal');
end
end