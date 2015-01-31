classdef (Abstract = true) nDGridData
    %nDGridData: Abstract base class defining common properties to all images.
    % Abstract class containing properties common to all image structures to are
    % derived from this class.
    
    properties
        nr = 0; % Number of rows (positive integer)
        nc = 0; % Number of columns (positive integer)
        nd = 1; % Number of frames (positive integer)
        
        br = 0; % Number of additional boundary rows on each side
        bc = 0; % Number of additional boundary columns on each side
        
        hr = 1.0; % Distance between two points along a row
        hc = 1.0; % Distance between two points along a column
    end
    
    properties (Abstract = true)
        pDim % Dimension of a pixel (number of channels), e.g. 1 for a scalar
             % valued image, 3 for an RGB image, [3, 3] for a tensor valued
             % image.
        
        p    % Array containing the pixel values. Its size is adapted to target
             % image model. Thus [nr, nc] for a gray scale image, [nr, nc, pDim]
             % for a multi channel image and [nr, nc, nd, pDim] for an image
             % sequence.
        
        rangeMin % minimal possible value in each channel (array of size pDim)
        rangeMax % maximal possible value in each channel (array of size pDim)
    end
    
    properties (Abstract = true, Hidden = true)
        isIndexed  % Wether the colours are index via a colourmap (logical)
        isSequence % Wether the image is actually a movie (logical)
    end
    
    methods
        function obj = nDGridData(nr, nc, varargin)
            
            narginchk(2, 7);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('nr', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nr'));
            
            parser.addRequired('nc', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nc'));
            
            parser.addOptional('nd', 1, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nd'));
            
            parser.addOptional('br', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'nDGridData', 'br'));
            
            parser.addOptional('bc', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'nDGridData', 'bc'));
            
            parser.addOptional('hr', 1.0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'positive'}, ...
                'nDGridData', 'hr'));
            
            parser.addOptional('hc', 1.0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'positive'}, ...
                'nDGridData', 'hc'));
            
            
            parser.parse(nr, nc, varargin{:});
            
            obj.nr = parser.Results.nr;
            obj.nc = parser.Results.nc;
            obj.nd = parser.Results.nd;
            
            obj.br = parser.Results.br;
            obj.bc = parser.Results.bc;
            
            obj.hr = parser.Results.hr;
            obj.hc = parser.Results.hc;
        end
    end
end

