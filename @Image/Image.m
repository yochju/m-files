classdef Image < double
    %Image Represents an image in form of an n-D array.
    %    Image is a subclass of double. An image can be any n x m x k double
    %    matrix where n, m are the image dimensions and k is the number of
    %    channels.
    %
    % Image Properties:
    %    padding      - The padding at the boundaries of the image.
    %    colorSpace   - The underlying colorspace of the data.
    %
    % Image Methods:
    %    pad         - pads data at the boundaries.
    %    dimChannels - returns the dimensions of the channels.
    %
    
    properties
        padding
        colorSpace        
    end
    
    methods
        function obj = Image(data, pad)
            %% Image(data, pad) creates an image from data with padding pad.
            %
            % Note that data must be a matrix with 2 or 3 dimensions. In the
            % former case it will be handled like a gray value (e.g. one channel
            % image) and in the latter case, the third dimension indicates the
            % number of channels. The default color space for single channeled
            % images is ColorSpace.Gray and for images with 3 channels it is
            % ColorSpace.RGB. In any other case it will be ColorSpace.Unknown.
            
            error(nargchk(0,2,nargin));
            error(nargoutchk(0,1,nargout));
            
            if nargin == 0
                data = [];
                pad = [0 0 0 0];
            elseif nargin == 1
                pad = [0 0 0 0];
            end
            
            dataSize = size(data);
            
            ExcM = ExceptionMessage('Input');
            
            assert( isnumeric(data), ...
                ExcM.id,ExcM.message);
            
            assert( length(dataSize) == 2 || length(dataSize) == 3 , ...
                ExcM.id, ExcM.message );
            
            assert( length(pad) == 4 , ...
                ExcM.id, ExcM.message );
            
            assert( all(IsInteger(pad)) && all(pad>=0) , ...
                ExcM.id, ExcM.message );
            
            if length(dataSize) == 2 && ~isempty(data)
                color = ColorSpace.Gray;
            elseif length(dataSize) == 3 && dataSize(3) == 3
                color = ColorSpace.RGB;
            else
                color = ColorSpace.Unknown;
            end
            
            obj = obj@double(data);
            obj.padding = pad;
            obj.colorSpace = color;
        end
    end
end

