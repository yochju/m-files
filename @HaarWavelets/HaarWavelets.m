classdef HaarWavelets < Wavelets
    properties (Access = protected)
        positions;
    end
    
    properties
        scale_coeffs;
        wave_coeffs;
        max_level;
    end
    
    methods
        function obj = HaarWavelets(signal)
            obj = obj@Wavelets(signal);
            N = length(signal);
            obj.positions = [1:N]-0.5;
            obj.max_level = log2(N);
        end
        
        [ c d ] = Transform(obj,level);
        [ c d ] = Decompose(obj);
        [ c d ] = ShrinkCoeffs(obj,level,f);
        sig = Reconstruct(obj,c,d);
        n = NumWavelets(obj,level);
    end
    
    methods (Static = true)
        y = Scalingfunction(x);
        y = Waveletfunction(x);
        y = Scalingbasis(i,j,x);
        y = Waveletbasis(i,j,x);
    end
end