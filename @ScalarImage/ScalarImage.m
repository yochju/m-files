classdef (Abstract = true) ScalarImage < nDGridData
    %ScalarImage Class for representing single channel images.
    % Intermediate class for images with scalar valued pixels. It serves as a
    % basis for setting up grey scale images (indexed and non-indexed images).
    % The image is an array of size [nr + 2*br, nc + 2*bc]. bc and br are dummy
    % boundaries used countless applications such as convolution filters.
    
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
    
    % Last revision on: 19.02.2015 20:00
    
    properties
        % For scalar valued images, out data is stored in a simple 2D
        % array. p(i,j) containts the pixel value at position (i,j).
        p = nan(1);
    end
    
    properties (Hidden = true, Access = protected, Constant = true)
        pDim = 1; % Dimension of a pixel (number of channels), e.g. 1 for a
                  % scalar valued image, 3 for an RGB image, [3, 3] for a tensor
                  % valued image. (array of integers)
        
        isSequence = false; % Wether the image is actually a movie (logical)
    end
    
    properties (Hidden = true)
        hd = 0.0;
    end
    
    properties (Hidden = true, SetAccess = protected)
        nd = 1;
    end
    
    %% Methods
    
    methods (Access = private)
        function obj = Scalarfilter(obj, mask, f)
            %% Apply a (weighted) local nonlinear filter function
            %
            % out = Scalarfilter(in, mask)
            %
            % Input parameters (required):
            %
            % obj  : ScalarImage object.
            % mask : 2D array with odd number of rows and columns. Center will
            %        be the mid pixel along every direction. Entries serve as
            %        weights. NaNs mark pixels to be ignored.
            % f    : handle to a function that can take arbitrary sized vectors
            %        and returns a scalar.
            %
            % Output parameters:
            %
            % obj : Filtered image.
            %
            % Description:
            %
            % If all mask values are 1, then a much faster code is applied than
            % if the mask values are not all the 1.

            narginchk(3, 3);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'Scalarfilter', 'obj'));
            parser.addRequired('mask', @(x) validateattributes( x, ...
                {'numeric'}, {'2d'}, 'Scalarfilter', 'mask'));
            parser.addRequired('f', @(x) validateattributes( x, ...
                {'function_handle'}, {}, 'Scalarfilter', 'f'));
            
            parser.parse(obj, mask, f);

            SigSize = size(obj.p);
            WinSize = size(mask);
            
            if any(mask(:) ~= 1)
                %% Slow approach with weighting
                M = im2col(padarray(ones(SigSize), floor(WinSize/2), nan), ...
                    WinSize, 'sliding');
                S = im2col(padarray(obj.p, floor(WinSize/2), nan), ...
                    WinSize, 'sliding');
                S = S .* M .* repmat(mask(:), [1 size(M, 2)]);
                obj.p = col2im(f(S), [1 1], SigSize);
            else
                %% Fast approach with full mask of ones.
                tmp = colfilt(padarray(obj.p, floor(WinSize/2), nan), ...
                    WinSize, 'sliding', f);
                bdsiz = floor(WinSize/2);
                obj.p = tmp(bdsiz(1)+(1:SigSize(1)), bdsiz(2)+(1:SigSize(2)));
            end
        end
    end
          
    methods
        function obj = ScalarImage(nr, nc, varargin)
            %% Constructor for ScalarImage.
            %
            % Usage is the same as for nDGridData.
            
            narginchk(2, 6);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('nr', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nr'));
            
            parser.addRequired('nc', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'nDGridData', 'nc'));
            
            parser.addOptional('br', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'nDGridData', 'br'));
            
            parser.addOptional('bc', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'nDGridData', 'bc'));
            
            parser.parse(nr, nc, varargin{:});

            obj = obj@nDGridData(nr, nc);
            
            obj.p = nan(obj.nr + 2*parser.Results.br, ...
                obj.nc + 2*parser.Results.bc);
        end
        
        function obj = set.p(obj, vals)
            if (any(vals(:) < obj.rangeMin)||any(vals(:) > obj.rangeMax))
                %% Emit a warning if assigned value is not within range
                MExc = ExceptionMessage('BadArg', ...
                    'message', 'Data leaves admissible range.');
                warning(MExc.id, MExc.message);
            end
            
            obj.p = vals;
        end
           
        function obj = pad(obj, varargin)
            %% Provide dummy boundary for the image.
            %
            % out = pad(obj)
            % out = pad(obj, padsize)
            % out = pad(obj, padsize, padval)
            % out = pad(obj, padsize, padval, direction)
            %
            % Input parameters (required):
            %
            % obj : A ScalarImage object
            %
            % Optional parameters:
            %
            % padsize   : How many pixels along each dimension should be padded.
            %             Default is [1, 1].
            % padval    : Value to be used for the padding. Default is 0.
            % direction : Direction used for the padding. Either 'left',
            %             'right' or 'both' to indicate the side on which the
            %             padding will be applied. Default is 'both'.
            %
            % Output parameters:
            %
            % A ScalarImage object with padded boundaries.
            %
            % Description
            %
            % Acts as a wrapper function around padarray from the image
            % processing toolbox. Arguments are only checked for their existence
            % and given sane default values if missing. Otherwise everything is
            % left to padarray. Images can be padded several times. Each time
            % the padding is added to br and bc.
            
            narginchk(1, 7);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'pad', 'obj'));
            
            parser.addOptional('padsize', [1, 1]);
            parser.addOptional('padval', 0);
            parser.addOptional('direction', 'both'); % TODO: fails, it cannot be
            % set properly without the direction keyword.
                        
            parser.parse(obj, varargin{:});
            
            obj.p = padarray(obj.p, parser.Results.padsize, ...
                parser.Results.padval, parser.Results.direction);
        end
                
        function save(obj, fname, varargin)
            %% Write Image to disk.
            % Acts as a wrapper function around imwrite.
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'load', 'obj'));
            parser.addRequired('fname', @(x) validateattributes( x, ...
                {'char'}, {'nonempty'}, 'load', 'fname'));
            
            parser.parse(obj, fname);
            
            imwrite(obj.p, parser.Results.fname, varargin{:});
        end
        
        function obj = load(obj, fname, varargin)
            %% Load image from disk.
            % Acts as a wrapper function around imread.
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'load', 'obj'));
            parser.addRequired('fname', @(x) validateattributes( x, ...
                {'char'}, {'nonempty'}, 'load', 'fname'));
            
            parser.parse(obj, fname);
            
            tmp = imread(parser.Results.fname, varargin{:});
            obj.nr = size(tmp, 1);
            obj.nc = size(tmp, 2);
            obj.br = 0;
            obj.bc = 0;
            obj.p = tmp;
        end
        
        function out = vec(obj, varargin)
            %% Return 1D array containing the image pixels.
            %
            % out = vec(obj)
            % out = vec(obj, ordering)
            %
            % Input parameters (required):
            %
            % obj : A ScalarImage object
            %
            % Optional parameters:
            %
            % ordering : either 'row-wise' or 'column-wise' to indicate in which
            %            order the pixels should be traversed. Default is
            %            column-wise, which corresponds with the default matlab
            %            ordering.
            %
            % Output parameters:
            %
            % out : a 1D array containing all pixel values.
            %
            % Description:
            %
            % Runs linearly over all pixel and returns them in a simple 1D
            % array.
            
            narginchk(1, 2);
            nargoutchk(0, 1);
            
            parser = inputParser;
 
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'load', 'obj'));
            
            parser.addOptional('ordering', 'column-wise', @(x) strcmpi(x, ...
                validatestring( x, {'row-wise', 'column-wise'}, ...
                'vec', 'ordering') ) );

            parser.parse(in, varargin{:});
            
            if strcmpi(parser.Results.ordering, 'row-wise')
                tmp = (obj.p)';
                out = tmp(:);
            else
                out = obj.p(:);
            end
            
        end
        
        function obj = reshape(obj, nr, nc, varargin)
            %% Change image shape.
            %
            % obj = reshape(obj, nr, nc)
            % obj = reshape(obj, nr, nc, br)
            % obj = reshape(obj, nr, nc, br, bc)
            %
            % Input parameters (required):
            %
            % obj : A ScalarImage object
            % nr  : Number of rows. (positive integer)
            % nc  : Number of coloumns. (positive integer)
            %
            % Input parameters (optional):
            %
            % br : Number of dummy rows. (nonnegative integer)
            % bc : Number of dummy coloumns. (nonnegative integer)
            %
            % Output parameters:
            %
            % obj : a ScalarImage with reshaped pixel data array.
            %
            % Description:
            %
            % This is a wrapper function around the builtin function reshape.
            % Note that not all options from the original reshape function are
            % supported.
            
            narginchk(3, 7);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'reshape', 'obj'));
            
            parser.addRequired('nr', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'reshape', 'nr'));
            
            parser.addRequired('nc', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'reshape', 'nc'));
            
            parser.addOptional('br', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'reshape', 'br'));
            
            parser.addOptional('bc', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'reshape', 'bc'));
            
            parser.parse(obj, nr, nc, varargin{:});
            
            obj.p = reshape(obj.p, ...
                [parser.Results.nr + 2*parser.Results.br, ...
                parser.Results.nc + 2*parser.Results.bc]);
            obj.nr = parser.Results.nr;
            obj.nc = parser.Results.nc;
        end
        
        function obj = resize(obj, nr, nc, varargin)
            %% Change image size
            %
            % obj = resize(obj, nr, nc)
            % obj = resize(obj, nr, nc, br)
            % obj = resize(obj, nr, nc, br, bc)
            %
            % Input parameters (required):
            %
            % obj : A ScalarImage object
            % nr  : Number of rows. (positive integer)
            % nc  : Number of coloumns. (positive integer)
            %
            % Input parameters (optional):
            %
            % br : Number of dummy rows, 0 by default. (nonnegative integer)
            % bc : Number of dummy coloumns, 0 by default. (nonnegative integer)
            %
            % Output parameters:
            %
            % obj : a ScalarImage with reshaped pixel data array.
            %
            % Description:
            %
            % This is a wrapper function around the imresize function from the
            % image processing toolbox. Note that not all options from the
            % original imresize function are supported.
            
            narginchk(3, 7);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'reshape', 'obj'));
            
            parser.addRequired('nr', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'reshape', 'nr'));
            
            parser.addRequired('nc', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'reshape', 'nc'));
            
            parser.addOptional('br', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'reshape', 'br'));
            
            parser.addOptional('bc', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'reshape', 'bc'));
            
            parser.parse(obj, nr, nc, varargin{:});
            
            obj.p = imresize(obj.p, ...
                [parser.Results.nr + 2*parser.Results.br, ...
                parser.Results.nc + 2*parser.Results.bc]);
            obj.nr = parser.Results.nr;
            obj.nc = parser.Results.nc;
        end
        
        function val = maxval(obj)
            %% Returns the maximal pixel value.
            %
            % This method should be faster than the version in nDGridData.
            
            narginchk(1, 1);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'reshape', 'obj'));
            
            parser.parse(obj);

            val = max(obj.p(:));
        end
        
        function val = minval(obj)
            %% Returns the maximal pixel value.
            %
            % This method should be faster than the version in nDGridData.
            
            narginchk(1, 1);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'reshape', 'obj'));
            
            parser.parse(obj);

            val = min(obj.p(:));
        end
        
        function obj = minfilter(obj, mask)
            %% Apply a (weighted) minimum filter.
            %
            % out = minfilter(in, mask)
            %
            % Input parameters (required):
            %
            % obj  : ScalarImage object.
            % mask : 2D array with odd number of rows and columns. Center will
            %        be the mid pixel along every direction. Entries serve as
            %        weights. NaNs mark pixels to be ignored.
            %
            % Output parameters:
            %
            % obj : Filtered image.
            %
            % Description:
            %
            % If all mask values are 1, then a much faster code is applied than
            % if the mask values are not all the 1.

            narginchk(2, 2);
            nargoutchk(0, 1);
            
            obj = obj.Scalarfilter(mask, @min);
        end
        
        function obj = maxfilter(obj, mask)
            %% Apply a (weighted) maximum filter.
            %
            % out = maxilter(in, mask)
            %
            % Input parameters (required):
            %
            % obj  : ScalarImage object.
            % mask : 2D array with odd number of rows and columns. Center will
            %        be the mid pixel along every direction. Entries serve as
            %        weights. NaNs mark pixels to be ignored.
            %
            % Output parameters:
            %
            % obj : Filtered image.
            %
            % Description:
            %
            % If all mask values are 1, then a much faster code is applied than
            % if the mask values are not all the 1.

            narginchk(2, 2);
            nargoutchk(0, 1);
            
            obj = obj.Scalarfilter(mask, @max);
        end
        
        function obj = meanfilter(obj, mask)
            %% Apply a (weighted) mean filter.
            %
            % out = meanfilter(in, mask)
            %
            % Input parameters (required):
            %
            % obj  : ScalarImage object.
            % mask : 2D array with odd number of rows and columns. Center will
            %        be the mid pixel along every direction. Entries serve as
            %        weights. NaNs mark pixels to be ignored.
            %
            % Output parameters:
            %
            % obj : Filtered image.
            %
            % Description:
            %
            % If all mask values are 1, then a much faster code is applied than
            % if the mask values are not all the 1.

            narginchk(2, 2);
            nargoutchk(0, 1);
            % builtin mean function cannot handle nans.
            obj = obj.Scalarfilter(mask, @nanmean);
        end
        
        function obj = medianfilter(obj, mask)
            %% Apply a (weighted) median filter.
            %
            % out = meanfilter(in, mask)
            %
            % Input parameters (required):
            %
            % obj  : ScalarImage object.
            % mask : 2D array with odd number of rows and columns. Center will
            %        be the mid pixel along every direction. Entries serve as
            %        weights. NaNs mark pixels to be ignored.
            %
            % Output parameters:
            %
            % obj : Filtered image.
            %
            % Description:
            %
            % If all mask values are 1, then a much faster code is applied than
            % if the mask values are not all the 1.

            narginchk(2, 2);
            nargoutchk(0, 1);
            % builtin median function cannot handle nans.
            obj = obj.Scalarfilter(mask, @nanmedian);
        end
        
        function val = mse(obj, obj2)
            %% Compute Mean Square Error
            %
            % Returns squared euclidean distance divided by number of pixels.
            
            narginchk(2, 2);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'mse', 'obj'));
            parser.addRequired('obj2', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'mse', 'obj2'));
            
            parser.parse(obj, obj2);
            
            if eqDims(obj, obj2)
                val = sum((obj.p(:)-obj2.p(:)).^2)/numel(obj.p);
            else
                MExc = ExceptionMessage('BadArg', 'message', ...
                    'Images have different shapes.');
                error(MExc.id, MExc.message);
            end
        end
    end
    
end

