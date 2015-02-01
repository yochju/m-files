classdef ScalarImage < nDGridData
    %RasterImage Class for representing single channel images.
    %   Detailed explanation goes here
    
    properties
        p = nan(1);
    end
    
    properties (Constant = true)
        rangeMin = 0;
        rangeMax = 1;
    end
    
    properties (Hidden = true, Access = protected, Constant = true)
        pDim = 1; % Dimension of a pixel (number of channels), e.g. 1 for a scalar
                  % valued image, 3 for an RGB image, [3, 3] for a tensor valued
                  % image. (array of integers)
        
        isIndexed = false; % Wether the colours are indexed via a colourmap (logical)
        isSequence = false; % Wether the image is actually a movie (logical)
    end
    
    properties (Hidden = true)
        nd = 1;
        hd = 0.0;
    end
          
    methods
        function obj = ScalarImage(nr, nc, varargin)
            
            narginchk(2, 4);
            nargoutchk(0, 1);
            
            obj = obj@nDGridData(nr, nc);
        end
    end
    
end

