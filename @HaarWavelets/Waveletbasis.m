function y = Waveletbasis(i,j,x)
y = 2^(-i/2)*HaarWavelets.Waveletfunction(2^(-i)*x-j);
end