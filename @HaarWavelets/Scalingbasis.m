function y = Scalingbasis(i,j,x)
y = 2^(-i/2)*HaarWavelets.Scalingfunction(2^(-i)*x-j);
end