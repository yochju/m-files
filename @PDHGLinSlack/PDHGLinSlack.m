classdef PDHGLinSlack < PDHG
    
    % Todo: Some properties are dependent. Implement this!!!
    properties
        op
        rhs
    end
    
    properties ( Access = private )
        q1
        q2
        x
        xold
        xbar
        d
        dold
        dbar
    end
    
    
    methods
        
        function obj = PDHGLinSlack(op,rhs)
            obj.op = op;
            obj.rhs = rhs;
            
            obj.tau = 0;
            obj.sigma = 0;
            obj.theta = 0;
            obj.primResolvent = @(x,y) ...
                [ x ; y ];
            obj.dualResolvent = @(x,y) ...
                [ 1/(1+obj.sigma)*x ; y + obj.sigma * obj.rhs ]; % !!
            
            obj.pvar = zeros(sum(size(op)),1);
            obj.pvarold = zeros(sum(size(op)),1);
            obj.pvarbar = zeros(sum(size(op)),1);
            obj.dvar = zeros(2*size(op,1),1);
            
            obj.q1 = zeros(size(op,1),1);
            obj.q2 = zeros(size(op,1),1);
            obj.x = zeros(size(op,2),1);
            obj.xold = zeros(size(op,2),1);
            obj.xbar = zeros(size(op,2),1);
            obj.d = zeros(size(op,1),1);
            obj.dold = zeros(size(op,1),1);
            obj.dbar = zeros(size(op,1),1);
        end
        
        function val = returnResult(obj)
            val = obj.xbar;
        end
        
    end
    
    methods ( Access = protected )
        function updateDual(obj)
            vq = obj.dualResolvent( ...
                obj.DuRHS1() , obj.DuRHS2() );
            obj.q1 = vq(1:size(obj.op,1)) ;
            obj.q2 = vq((size(obj.op,1)+1):end);
            obj.dvar = vq;
        end
        
        function updatePrimal(obj)
            obj.pvarold = obj.pvar;
            obj.xold = obj.x;
            obj.dold = obj.d;
            vn = obj.primResolvent( ...
                obj.PrRHS1() , obj.PrRHS2() );
            obj.x = vn(1:size(obj.op,1));
            obj.d = vn((1+size(obj.op,1)):end);
            obj.pvar = vn;
        end
        
        function extrapolate(obj)
            obj.xbar = (1 + obj.theta) * obj.x - obj.xold;
            obj.dbar = (1 + obj.theta) * obj.d - obj.dold;
            obj.pvarbar = (1 + obj.theta) * obj.pvar - obj.pvarold;
        end
    end
    
    methods ( Access = private )
        
        function z = DuRHS1(obj)
            z = obj.q1 + obj.sigma * obj.dbar;
        end
        
        function z = DuRHS2(obj)
            z = obj.q2 + obj.sigma * ( obj.dbar - obj.op * obj.xbar );
        end
        
        function z = PrRHS1(obj)
            z = obj.x + obj.tau * obj.op' * obj.q2;
        end
        
        function z = PrRHS2(obj)
            z = obj.d - obj.tau * ( obj.q1 + obj.q2 );
        end
        
    end
    
end

