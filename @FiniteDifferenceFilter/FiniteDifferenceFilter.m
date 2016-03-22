classdef FiniteDifferenceFilter
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        knots        = [];
        coefficients = [];
        order        = -1
        gridSize     =  0.0;
        consistency  = -1;
        boundary     = 'Neumann';
    end
    
    properties (Hidden = true, Access = private)
        tolerance = 1e-12;
    end
        
    methods
        function obj = FiniteDifferenceFilter(knots, order, varargin)
        end
        
        function coeffs = ComputeWeights(obj)
        end
        
        function sigOut = ApplyToSignal(obj, sigIn)
        end
        
        function mat = ToMatrix(obj)
        end
    end
    
end

