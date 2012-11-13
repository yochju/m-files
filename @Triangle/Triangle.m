classdef Triangle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        p1 = [0; 0];
        p2 = [1; 0];
        p3 = [0; 1];
    end
    
    properties (Dependent = true, SetAccess = private)
        Determ
    end
        
    methods
        function obj = Triangle(p1, p2, p3)
            switch nargin
                case 0
                %% No parameters passed. Use default values.

                case 1
                %% All 3 corners are passed in first argument as a 2x3 array.
                ExcM = ExceptionMessage('Input');
                assert(isequal(size(p1), [2 3]) || isequal(size(p1), [3 2]), ...
                    ExcM.id, ExcM.message);
                
                if isequal(size(p1),[2 3])
                    obj.p1 = p1(:,1);
                    obj.p2 = p1(:,2);
                    obj.p3 = p1(:,3);
                else
                    obj.p1 = p1(1,:);
                    obj.p2 = p1(2,:);
                    obj.p3 = p1(3,:);
                end
                
                case 3
                %% All 3 corners are passed separately.
                ExcM = ExceptionMessage('Input');
                assert(isequal(size(p1),[2 1]) || isequal(size(p1),[1 2]), ...
                    ExcM.id, ExcM.message);
                assert(isequal(size(p2),[2 1]) || isequal(size(p2),[1 2]), ...
                    ExcM.id, ExcM.message);
                assert(isequal(size(p3),[2 1]) || isequal(size(p3),[1 2]), ...
                    ExcM.id, ExcM.message);
                
                obj.p1 = p1(:);
                obj.p2 = p2(:);
                obj.p3 = p3(:);
                
                otherwise
                %% No valid combination of arguments passed.
                ExcM = ExceptionMessage('Input');
                error(ExcM.id,ExcM.message);
            end
        end
        
        function Determ = get.Determ(obj)
            Determ = det(Triangle.TransM(obj.p1,obj.p2,obj.p3));
        end
                
        function y = basis1h(obj,x)
            y = det(TransM(obj.p2,x,obj.p3))/obj.Determ;
        end
        
        function y = basis2h(obj,x)
            y = det(TransM(obj.p1,x,obj.p3))/obj.Determ;
        end
        
        function y = basis3h(obj,x)
            y = det(TransM(obj.p1,x,obj.p2))/obj.Determ;
        end
        
        function y = Integrate(obj,fun)
            f = @(x) fun(FromStd(x,obj.p1,obj.p2,obj.p3));
            y =abs(obj.Determ)*quad2d(f,0,1,0,@(x) 1-x);
        end
        
% P gibt den Wert der Bilinearen Interpolation an der Stelle p zurück.
% Die Ebene geht durch die Punkte r1,r2,r3 und hat die Funktionswerte z1, z2, z3.
% P[p_,z1_,z2_,z3_,r1_,r2_,r3_]:=z1*b1[p,r1,r2,r3]+z2*b2[p,r1,r2,r3]+z3*b3[p,r1,r2,r3];

    end
    
    methods (Static = true, Access = private)
        
        function y = FromStd(x,p1,p2,p3)
            M = Triangle.TransM(p1,p2,p3);
            y = M*x + p1;
        end
        
        function y = ToStd(x,p1,p2,p3)
            M = fliplr([0 -1; -1 0].*[(p1-p3)';(p1-p2)'])/ ...
                det(Triangle.TransM(p1,p2,p3));
            y = M*(x-p1);
        end
        
        function M = TransM(p1,p2,p3)
            M = [p2-p1 p3-p1];
        end
        
    end
end

