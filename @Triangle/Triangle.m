classdef Triangle
    %Provides functionality for computations on 2D Triangular domains.
    %   Provides functionality for handling 2D triangular domains in the context
    %   of interpolation and partial differential equations.
    
    % Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
    %
    % This program is free software; you can redistribute it and/or modify it
    % under the terms of the GNU General Public License as published by the Free
    % Software Foundation; either version 3 of the License, or (at your option)
    % any later version.
    %
    % This program is distributed in the hope that it will be useful, but
    % WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    % or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    % for more details.
    %
    % You should have received a copy of the GNU General Public License along
    % with this program; if not, write to the Free Software Foundation, Inc., 51
    % Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
    
    % Last revision on: 14.11.2012 21:30
    
    properties
        % A triangle is uniquely defined by the position of its 3 corner points.
        % If none are specified during construction, we assume that the standard
        % triangle with its corners on the x- and y- axis and unit length should
        % be used.
        p1 = [0; 0];
        p2 = [1; 0];
        p3 = [0; 1];
    end
    
    properties (Dependent = true, SetAccess = private)
        Determ % Determinant of the transformation matrix.
    end
        
    methods
        function obj = Triangle(p1, p2, p3)
            %% Constructor
            %
            % obj = Triangle(p1, p2, p3)
            %
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
                assert( Triangle.ValidPoints(p1,p2,p3), ExcM.id, ExcM.message);

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
            %% Determinant of the transformation matrix.
            %
            % Determ = get.Determ(obj)
            %
            
            Determ = det(Triangle.TransM(obj.p1,obj.p2,obj.p3));
        end
        
        function bool = IsInside(obj,p)
            %% Checks whether coordinates p lie inside the Triangle or not.
            %
            % bool = IsInside(obj,p)
            %
            
            ExcM = ExceptionMessage('Input');
            assert( Triangle.ValidPoints(p,[0;0],[0;0]), ExcM.id, ExcM.message);
            
            q = Triangle.ToStd(p(:),obj.p1,obj.p2,obj.p3);
            if (( 0<=q(1) && q(1)<=1 ) && ( 0<=q(2) && q(2)<=(1-q(1)) ))
                bool = true;
            else
                bool = false;
            end
        end
                        
        function y = IntegrateBilinear(obj,v1,v2,v3)
            %% Bilinear integration.
            %
            % y = IntegrateBilinear(obj,v1,v2,v3)
            %
            % Integrates the bilinear interpolant which passes through the
            % corners p1, p2 and p3 with values v1, v2 and v3.
            
            y = (v1+v2+v3)/6*abs(obj.Determ);
        end
        
        function y = InterpolateBilinear(obj,p,v1,v2,v3)
            %% Bilinear interpolation.
            %
            % y = InterpolateBilinear(obj,p,v1,v2,v3)
            %
            % Evaluates the bilinear interpolant  which passes through the
            % corners p1, p2 and p3 with values v1, v2 and v3 at position p.
            
            ExcM = ExceptionMessage('Input');
            assert( Triangle.ValidPoints(p,[0;0],[0;0]), ExcM.id, ExcM.message);
            assert( isequal(size([v1 v2 v3]), [1 3]), ExcM.id, ExcM.message);
            assert( IsInside(obj,p), ExcM.id, ExcM.message);
            
            y = v1*obj.basis1h(p) + v2*obj.basis2h(p) + v3*obj.basis3h(p);
        end
        
        function [dx dy] = GradientBilinear(obj,v1,v2,v3)
            %% Compute the gradient of the bilinear interpolant.
            %
            % [dx dy] = GradientBilinear(obj,v1,v2,v3)
            %
            
            n = cross( ...
                [obj.p2(:); v2]-[obj.p1(:); v1], ...
                [obj.p3(:); v3]-[obj.p1(:); v1]);
            if n(3)==0
                dx = 0;
                dy = 0;
            else
                dx = -n(1)/n(3);
                dy = -n(2)/n(3);
            end
            
        end
        
        function [a b c d] = PlaneEquation(obj,v1,v2,v3)
            %% Compute the coefficients of the plane equation
            %
            % [a b c d] = GradientBilinear(obj,v1,v2,v3)
            %
            % Equation is: a*x + b*y + c*z = d.
            
            n = cross( ...
                [obj.p2(:); v2]-[obj.p1(:); v1], ...
                [obj.p3(:); v3]-[obj.p1(:); v1]);
            a = n(1);
            b = n(2);
            c = n(3);
            d = obj.p1(1)*n(1)+obj.p1(2)*n(2)+v1*n(3);
            
        end
    end
    
    methods (Access = private)
        
        function y = basis1h(obj,x)
            %% First triangle basis function.
            %
            % y = basis1h(obj,x)
            %
            
            y = det(Triangle.TransM(obj.p3,x,obj.p2))/obj.Determ;
        end
        
        function y = basis2h(obj,x)
            %% Second triangle basis function.
            %
            % y = basis2h(obj,x)
            %
            
            y = det(Triangle.TransM(obj.p1,x,obj.p3))/obj.Determ;
        end
        
        function y = basis3h(obj,x)
            %% Third triangle basis function.
            %
            % y = basis3h(obj,x)
            %
            
            y = det(Triangle.TransM(obj.p2,x,obj.p1))/obj.Determ;
        end
        
    end
    
    methods (Static = true)
        
        function y = FromStd(x,p1,p2,p3)
            %% Transfrom from standard triangle to arbitrary triangle.
            %
            % y = FromStd(x,p1,p2,p3)
            %
            % Transforms coordinates x in triangle T(p1,p2,p3) to coordinates in
            % the standard triangle through an affine transformation.
            
            M = Triangle.TransM(p1,p2,p3);
            y = M*x + p1;
        end
        
        function y = ToStd(x,p1,p2,p3)
            %% Transform from arbitrary triangle to standard triangle.
            %
            % y = ToStd(x,p1,p2,p3)
            %
            % Inverse to Triangle.FromStd. Transforms coordinates x in standard
            % triangle to coordinates in arbitrary triangle T(p1,p2,p3) through
            % an affine transform.
            
            M = fliplr([0 -1; -1 0].*[(p1-p3)';(p1-p2)'])/ ...
                det(Triangle.TransM(p1,p2,p3));
            y = M*(x-p1);
        end
        
    end
    
    methods (Static = true, Access = private)
        
        function bool = ValidPoints(p1,p2,p3)
            %% Checks whether p1, p2, p3 are 2x1 or 1x2 arrays.
            %
            % bool = ValidPoints(p1,p2,p3)
            
            if nargin == 1
                if (isequal(size(p1), [2 3]) || isequal(size(p1), [3 2]))
                    bool = true;
                else
                    bool = false;
                end
            elseif nargin == 3
                if ~isequal(size(p1(:)), [2,1])
                    bool = false;
                elseif ~isequal(size(p2(:)), [2,1])
                    bool = false;
                elseif ~isequal(size(p3(:)), [2,1])
                    bool = false;
                else
                    bool = true;
                end
            end
        end
        
        function M = TransM(p1,p2,p3)
            %% Transformation matrix.
            %
            % M = TransM(p1,p2,p3)
            %
            % Transformation matrix for changing an arbitrary triangle in to a
            % standard triangle. Shift onto the origin cannot be represent by
            % this matrix. Just the rotation and the scaling.
            
            M = [p2-p1 p3-p1];
        end
        
    end
end

