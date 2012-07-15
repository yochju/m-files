classdef Image < double
    %Image Represents an image in form of an n-D array.
    %    Image is a subclass of double. The first two indices contain the pixel
    %    location. All the following indices refer to channels. By default, it
    %    is assumed that the image has only a single channel.
    %
    % Image Properties:
    %    padding      - The padding at the boundaries of the image.
    %    colorSpace   - The underlying colorspace of the data. [not implemented]
    %    quantization - The underlying quantization [not implemented]
    %
    % Image Methods:
    %    pad         - pads data at the boundaries.
    %    dimChannels - returns the dimensions of the channels.
    %
    
    properties
        padding      % [top left bottom right]
        colorSpace   % FIXME: Gray, RGB, HSV, ...
        quantization % FIXME: uint8, ...
    end
    
    methods
        function obj = Image(data,pad)
            if nargin == 0
                data = [];
                pad = [0 0 0 0];
            elseif nargin == 1
                pad = [0 0 0 0];
            end
            obj = obj@double(data);
            obj.padding = pad;
        end
    end
end

