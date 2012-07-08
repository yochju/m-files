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
    end
    
    methods
        function obj = Image(varargin)
            % Same usage as e.g. 'ones'. Last argument will be padding.
            switch nargin
                case 0
                    data = [];
                    pad = [0 0 0 0];
                case 1
                    % FIXME: This isn't perfect. The following case is
                    % ambiguous: Image([3 4 5])
                    if isscalar(varargin{1}) || ...
                            (isrow(varargin{1}) && ...
                            (floor(varargin{1}) == ceil(varargin{1})))
                        data = zeros(varargin{1});
                    elseif ismatrix(varargin{1})
                        data = varargin{1};
                    end
                        pad = [0 0 0 0];
                case 2
                    if isscalar(varargin{1})
                        data = zeros(varargin{1},varargin{2});
                        pad = [0 0 0 0];
                    else
                        ExcM = ExceptionMessage('Input');
                        
                        assert(isvector(varargin{1}) && ...
                            isvector(varargin{2}) && ...
                            length(varargin{2}) == 4, ...
                            ExcM.id,ExcM.message);
                        
                        data = zeros(varargin{1});
                        pad = varargin{2};
                    end
                otherwise
                    ExcM = ExceptionMessage('Input');
                        
                    for i = 1:(length(varargin)-1)
                        assert(isscalar(varargin{i}),ExcM.id,ExcM.message);
                    end
                    
                    assert(isvector(varargin{end}) && ...
                        length(varargin{end}) == 4, ...
                        ExcM.id,ExcM.message);

                    data = zeros(varargin{1:(end-1)});
                    pad = varargin{end};
            end
            obj = obj@double(data);
            obj.padding = pad;
        end
    end
end

