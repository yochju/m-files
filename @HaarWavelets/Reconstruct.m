function sig = Reconstruct(obj,c,d)

if nargin > 1
    ct = c;
    dt = d;
else
    ct = obj.scale_coeffs;
    dt = obj.wave_coeffs;
end

sig = ct{1}(1)*HaarWavelets.Scalingbasis(obj.max_level,0,obj.positions);
for i = 0:(obj.max_level-1)
    for j = 0:(obj.NumWavelets(i)-1)
        sig = sig + dt{i+1}(j+1)*HaarWavelets.Waveletbasis(obj.max_level-i,j,obj.positions);
    end
end
end