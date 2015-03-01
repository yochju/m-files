classdef DoubleImageTest < matlab.unittest.TestCase
    % Unit test class for DoubleImage

    % Copyright 2015 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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
    
    % Last revision on: 01.03.2015 09:00
    
    methods (Test)
        function CreateImageTest(TestCase)
            %% Create image and check that default values are set.
            
            img = DoubleImage(3, 4);
            
            % Check that default properties are correctly set.
            TestCase.verifyEqual(img.nr, 3);
            TestCase.verifyEqual(img.nc, 4);
            TestCase.verifyEqual(img.br, 0);
            TestCase.verifyEqual(img.bc, 0);
            TestCase.verifyEqual(img.hr, 1.0);
            TestCase.verifyEqual(img.hc, 1.0);
            TestCase.verifyEqual(img.rangeMin, 0.0);
            TestCase.verifyEqual(img.rangeMax, 1.0);
            TestCase.verifyEqual(img.colsp, ColourSpace.None);
            
            img2 = DoubleImage(3, 4, 6);
            
            % Check that default properties are correctly set.
            TestCase.verifyEqual(img2.nr, 3);
            TestCase.verifyEqual(img2.nc, 4);
            TestCase.verifyEqual(img2.br, 6);
            TestCase.verifyEqual(img2.bc, 0);
            
            img3 = DoubleImage(3, 4, 6, 9);
            
            % Check that default properties are correctly set.
            TestCase.verifyEqual(img3.nr, 3);
            TestCase.verifyEqual(img3.nc, 4);
            TestCase.verifyEqual(img3.br, 6);
            TestCase.verifyEqual(img3.bc, 9);

        end
        
        
        function AdditionTest(TestCase)
            %% Check addition of images and other objects.
            
            img = DoubleImage(3, 4);
            img.p = 0.1*ones(3, 4);
            
            res = img + img;
            TestCase.verifyEqual(res.nr, 3);
            TestCase.verifyEqual(res.nc, 4);
            TestCase.verifyEqual(res.br, 0);
            TestCase.verifyEqual(res.bc, 0);
            TestCase.verifyEqual(res.p, 0.2*ones(3, 4), 'AbsTol', 1e-15);
                        
            res = img + 0.6;
            TestCase.verifyEqual(res.nr, 3);
            TestCase.verifyEqual(res.nc, 4);
            TestCase.verifyEqual(res.br, 0);
            TestCase.verifyEqual(res.bc, 0);
            TestCase.verifyEqual(res.p, 0.7*ones(3, 4), 'AbsTol', 1e-15);
            
            res = 0.2 + img;
            TestCase.verifyEqual(res.nr, 3);
            TestCase.verifyEqual(res.nc, 4);
            TestCase.verifyEqual(res.br, 0);
            TestCase.verifyEqual(res.bc, 0);
            TestCase.verifyEqual(res.p, 0.3*ones(3, 4), 'AbsTol', 1e-15);
            
        end
        
        
        function MaxValTest(TestCase)
            %% Test maxval method
            
            img = DoubleImage(3, 4);
            tmp = rand(3, 4);
            img.p = tmp;
            
            TestCase.verifyEqual(img.maxval, max(tmp(:)), 'AbsTol', 1e-15);
        end
        
        
        function MinValTest(TestCase)
            %% Test minval method
            
            img = DoubleImage(3, 4);
            tmp = rand(3, 4);
            img.p = tmp;
            
            TestCase.verifyEqual(img.minval, min(tmp(:)), 'AbsTol', 1e-15);
        end
        
        
        function SubImageTest(TestCase)
            %% Test subimage method
           
            img = DoubleImage(3, 4, 2, 2);
            tmp = bsxfun(@plus, (1:7)', 1:6);
            img.p = tmp/max(tmp(:));

            im2 = img.subimage([1, 3, 5], [2, 4]);
            
            TestCase.verifyEqual(class(im2), class(img));
            TestCase.verifyEqual(im2.nr, 3);
            TestCase.verifyEqual(im2.nc, 2);
            TestCase.verifyEqual(im2.br, 0);
            TestCase.verifyEqual(im2.bc, 0);
            TestCase.verifyEqual(im2.hr, 1.0);
            TestCase.verifyEqual(im2.hc, 1.0);
            TestCase.verifyEqual(im2.rangeMin, 0.0);
            TestCase.verifyEqual(im2.rangeMax, 1.0);
            TestCase.verifyEqual(im2.colsp, ColourSpace.None);
            
            TestCase.verifyEqual(im2.p, [3, 5; 5, 7; 7, 9]/max(tmp(:)), ...
                'AbsTol', 1e-15);
        end
    end
    
end

