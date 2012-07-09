classdef Image < double
    %Image Represents an image in form of an n-D array.
    %    Image is a subclass of double. The first two indices contain the pixel
    %    location. All the following indices refer to channels. By default, it
    %    is assumed that the image has only a single channel.
    
    % Image Properties:
    %    padding - The padding at the boundaries of the image.
    %
    % Image Methods:
    %
    
    properties
        padding % [top left bottom right]
        colorSpace % FIXME: Gray, RGB, HSV, ...
        quantization % FIXME: uint8, ...
    end
    
    methods
        function obj = Image(varargin)
            % Same usage as e.g. 'ones'. If more than one argument is specified
            % and if the last argument is a vector of length 4 with a class
            % different from char, then it is assumed to be the padding.
            % Otherwise it will be assumed to belong to the specification for
            % data.
            
            if nargin > 1 && ...
                    isvector(varargin{end}) && length(varargin{end}) == 4 && ...
                    ~ischar(varargin{end})
                data = zeros(varargin{1:(end-1)});
                pad = varargin{end};
            else
                data = zeros(varargin{1:end});
                pad = [0 0 0 0];
            end
            
            obj = obj@double(data);
            obj.padding = pad;
        end
    end
end

