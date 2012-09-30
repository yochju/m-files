classdef PDHGLinNoSlack < PDHG
        
    properties
        op
        rhs
    end
    
    methods
        function obj = PDHGLinNoSlack(op,rhs)
            
            % Super class properties (public)
            obj.tau = 0;
            obj.sigma = 0;
            obj.theta = 0;
            obj.dualResolvent = @(x) (x-obj.sigma*obj.rhs)/(1+obj.sigma);
            obj.primResolvent = @(x) x;
            
            % Super class properties (protected)
            obj.pvar = zeros(size(op,2),1);
            obj.pvarold = zeros(size(op,2),1);
            obj.pvarbar  = zeros(size(op,2),1);
            obj.dvar = zeros(size(op,1),1);
            
            % Class Methods
            obj.op = op;
            obj.rhs = rhs;
        end
               
    end
    
end

