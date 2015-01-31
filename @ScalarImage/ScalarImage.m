classdef ScalarImage < nDGridData
    %RasterImage Class for representing single channel images.
    %   Detailed explanation goes here
    
    properties
        pDim = 1;
        rangeMin = 0;
        rangeMax = 1;
        isIndexed = false;
        isSequence = false;
        p = nan(1);
    end
    
    methods
        function obj = ScalarImage(nr, nc, br, bc)
            
            narginchk(2, 4);
            nargoutchk(0, 1);
            
            obj = obj@nDGridData(nr, nc);
        end
    end
    
end

