classdef (Abstract = true) ScalarImage < nDGridData
    %ScalarImage Class for representing single channel images.
    % Intermediate class for images with scalar valued pixels. It serves as a
    % basis for setting up grey scale images (indexed and non-indexed images).
    % The image is an array of size [nr + 2*br, nc + 2*bc]. bc and br are dummy
    % boundaries used countless applications such as convolution filters.
    %
    % Note:
    % nDGridData and its derived classes heavily depend on functions contained
    % in the stats and image processing toolboxes.
    %
    % See also nDGridData, DoubleImage
    
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
    
    % Last revision on: 28.02.2015 20:00
    
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
            % out = Scalarfilter(in, mask, f)
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
        
        
        function obj = applyPixelArray(obj, val)
            %% Set obj.p to val and adapts dimensions.
            %
            % obj = obj.applyPixelArray(val)
            %
            % Resets nr and nc to size(val).
            
            narginchk(2, 2);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'applyPixelArray', 'obj'));
            
            parser.addRequired('val', @(x) validateattributes( x, ...
                {'numeric'}, {'2d', 'nonsparse', 'real', 'nonnan'}, ...
                'applyPixelArray', 'val'));
 
            obj.p = val;
            obj.nr = size(val, 1);
            obj.nc = size(val, 2);
        end
    end
          
    
    methods
        function obj = ScalarImage(nr, nc, varargin)
            %% Constructor for ScalarImage.
            %
            % Usage is the same as for nDGridData.
            %
            % See also nDGridData, DoubleImage
            
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

            obj = obj@nDGridData(nr, nc, varargin{:});
            
            obj.p = nan(obj.nr + 2*parser.Results.br, ...
                obj.nc + 2*parser.Results.bc);
        end
        
        
        function obj = set.p(obj, vals)
            %% Setter for pixel values
            if (any(vals(:) < obj.rangeMin)||any(vals(:) > obj.rangeMax))
                %% Emit a warning if assigned value is not within range
                MExc = ExceptionMessage('BadArg', ...
                    'message', 'Data leaves admissible range.');
                warning(MExc.id, MExc.message);
            end
            
            % TODO: Is it possible to adapt nr and nc and still using set.p?
            obj.p = vals;
        end
                   
        %% I/O methods
                
        function save(obj, fname, varargin)
            %% Write Image to disk.
            %
            % obj.save(fname)
            %
            % Acts as a wrapper function around imwrite.
            %
            % See also load
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'save', 'obj'));
            parser.addRequired('fname', @(x) validateattributes( x, ...
                {'char'}, {'nonempty'}, 'save', 'fname'));
            
            parser.parse(obj, fname);
            
            imwrite(obj.p, parser.Results.fname, varargin{:});
        end
        
        
        function obj = load(obj, fname, varargin)
            %% Load image from disk.
            %
            % obj.load(fname)
            %
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
        
        %% Structural manipulations of the image
        
        function sub = subimage(obj, rows, cols)
            %% Returns an part of the image
            %
            % sub = subimage(obj, rows, cols)
            %
            % Input parameters (required):
            %
            % obj  : A ScalarImage object
            % rows : Array containing the row indices to be extracted.
            % cols : Array containing the coloumn indices to extracted.
            %
            % Output parameters:
            %
            % A ScalarImage object containing the extracted data.
            %
            % Description
            %
            % Extracts data from an image object and creates a new object from
            % it.
            %
            % See also
            
            narginchk(3, 3);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'pad', 'obj'));
            parser.addRequired('rows', @(x) validateattributes( x, ...
                {'numeric'}, {'vector', 'integer', 'positive'}));
            parser.addRequired('cols', @(x) validateattributes( x, ...
                {'numeric'}, {'vector', 'integer', 'numel', numel(rows),...
                'positive'}));
            
            parser.parse(obj, rows, cols);
            
            sub = ScalarImage(numel(rows), numel(cols));
            sub.p = obj.p(rows, cols);
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
            %
            % See also padarray
            
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
                {'ScalarImage'}, {}, 'vec', 'obj'));
            
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
            %
            % See also imresize
            
            narginchk(3, 7);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'reshape', 'obj'));
            
            parser.addRequired('nr', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'resize', 'nr'));
            
            parser.addRequired('nc', @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'positive'}, ...
                'resize', 'nc'));
            
            parser.addOptional('br', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'resize', 'br'));
            
            parser.addOptional('bc', 0, @(x) validateattributes( x, ...
                {'numeric'}, {'scalar', 'integer', 'nonnegative'}, ...
                'resize', 'bc'));
            
            parser.parse(obj, nr, nc, varargin{:});
            
            obj.p = imresize(obj.p, ...
                [parser.Results.nr + 2*parser.Results.br, ...
                parser.Results.nc + 2*parser.Results.bc]);
            obj.nr = parser.Results.nr;
            obj.nc = parser.Results.nc;
        end
        
        
        function blcks = partition(obj, blcksiz)
            %% Partition image into blocks of size blcksiz
            %
            % blcks = obj.partition(blcksiz)
            %
            % See also mat2cell, cell2mat, num2cell
            
            narginchk(2, 2);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'maxval', 'obj'));
            
            parser.addRequired('blockSize', @(x) validateattributes( x, ...
                {'numeric'}, {'vector', 'integer', 'positive', 'numel', 2}, ...
                'partition', 'blockSize') );
            
            parser.parse(obj, blcksiz);
            opts = parser.Results;
            
            br = opts.blockSize(1);
            bc = opts.blockSize(2);
            
            [nr, nc] = size(in);
            
            MExc = ExceptionMessage('BadArg', 'message', 'Dimension mismatch');
            
            if ((mod(nr,br) ~= 0)||(mod(nc,bc) ~= 0))
                error(MExc.id, MExc.message);
            end
            
            blcks = mat2cell( obj.p , br*ones(1,nr/br) , bc*ones(1,nc/bc) );
        end
        
        %% Simple operations
        
        function obj = clip(obj, ran)
            %% Cutoff pixel values at specified bounds.
            
            narginchk(2, 2);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'clip', 'obj'));
            
            parser.addRequired('ran', @(x) validateattributes( x, ...
                {'numeric'}, {'vector', 'real', 'numel', 2}, ...
                'clip', 'ran') );
            
            parser.parse(obj, blcksiz);
            
            obj.p(obj.p > ran(1)) = ran(1);
            obj.p(obj.p < ran(2)) = ran(2);
        end
        
        
        function obj = binarise(obj, varargin)
            %% Binarise image
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'binarise', 'obj'));
  
            parser.addOptional('T', 0.5)
            
            parser.parse(obj, varargin{:});
            opts = parser.Results;
            
            % TODO: Add more methods like double thresholding and otsu.
            obj.p(obj.p >= opts.T) = obj.RangeMax;
            obj.p(obj.p < opts.T) = obj.RangeMin;
        end
        
        %% Statistical measures
        
        function val = maxval(obj)
            %% Returns the maximal pixel value.
            %
            % val = obj.maxval
            %
            % Input parameters (required):
            %
            % obj : ScalarImage object.
            %
            %
            % Output parameters:
            %
            % val : maximal pixel value inside obj.p
            %
            % This method should be faster than the version in nDGridData.
            %
            % See also max
            
            narginchk(1, 1);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'maxval', 'obj'));
            
            parser.parse(obj);

            val = max(obj.p(:));
        end
        
        
        function val = minval(obj)
            %% Returns the minimal pixel value.
            %
            % val = obj.minval
            %
            % Input parameters (required):
            %
            % obj : ScalarImage object.
            %
            % Output parameters:
            %
            % val : minimal pixel value inside obj.p
            %
            % This method should be faster than the version in nDGridData.
            %
            % See also min
            
            narginchk(1, 1);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'minval', 'obj'));
            
            parser.parse(obj);

            val = min(obj.p(:));
        end
        
        %% Morphological filters
        
        function obj = minfilter(obj, mask)
            %% Apply a (weighted) minimum filter. (Morpholgical erosion)
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
            %
            % See also maxfilter

            narginchk(2, 2);
            nargoutchk(0, 1);
            
            obj = obj.Scalarfilter(mask, @min);
        end
        
        
        function obj = maxfilter(obj, mask)
            %% Apply a (weighted) maximum filter. (Morpholgical dilation)
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
            %
            % See also minfilter

            narginchk(2, 2);
            nargoutchk(0, 1);
            
            obj = obj.Scalarfilter(mask, @max);
        end
        
        
        function obj = opening(obj, mask1, varargin)
            %% Perform morphological opening (with different masks).
            %
            % obj = obj.opening(ones(3,3))
            % obj = obj.opening(ones(3,3), ones(5,5))
            %
            % Input parameters:
            %
            % Output parameters:
            %
            % Description:
            %
            % See also closing
            
            narginchk(2, 3);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'opening', 'obj'));
            
            parser.addRequired('mask1', @(x) validateattributes( x, {'numeric'}, ...
                {'2d', 'nonsparse', 'nonempty'}, 'opening', 'mask1', 2) );
            
            parser.addOptional('mask2', mask1, @(x) validateattributes( x, ...
                {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, 'opening', ...
                'mask2', 3) );
            
            parser.parse(obj, mask1, varargin{:});

            obj = maxfilter(minfilter(obj, mask1), parser.Results.mask2);
        end
        
        
        function obj = closing(obj, mask1, varargin)
            %% Perform morphological closing (with different masks).
            %
            % obj = obj.closing(ones(3,3))
            % obj = obj.closing(ones(3,3), ones(5,5))
            %
            % Input parameters:
            %
            % Output parameters:
            %
            % Description:
            %
            % See also opening
            
            narginchk(2, 3);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'closing', 'obj'));
            
            parser.addRequired('mask1', @(x) validateattributes( x, {'numeric'}, ...
                {'2d', 'nonsparse', 'nonempty'}, 'closing', 'mask1', 2) );
            
            parser.addOptional('mask2', mask1, @(x) validateattributes( x, ...
                {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, 'closing', ...
                'mask2', 3) );
            
            parser.parse(obj, mask1, varargin{:});

            obj = minfilter(maxfilter(obj, mask1), parser.Results.mask2);
        end
        
        
        function obj = blacktophat(obj, mask1, varargin)
            %% Perform morphological black tophat
            %
            % obj = obj.blacktophat(ones(3,3))
            % obj = obj.blacktophat(ones(3,3), ones(5,5))
            % obj = obj.blacktophat(ones(3,3), ones(5,5), ones(1,1))
            % obj = obj.blacktophat(ones(3,3), ones(5,5), ones(1,1), ones(7,7))
            %
            % Input parameters:
            %
            % Output parameters:
            %
            % Description:
            %
            % See also whitetophat
            
            narginchk(2, 3);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'blacktophat', 'obj'));
            
            parser.addRequired('mask1', @(x) validateattributes( x, {'numeric'}, ...
                {'2d', 'nonsparse', 'nonempty'}, 'blacktophat', 'mask1', 2) );
            
            parser.addOptional('mask2', mask1, @(x) validateattributes( x, ...
                {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, 'blacktophat', ...
                'mask2', 3) );
            
            parser.parse(obj, mask1, varargin{:});

            obj = closing(obj, mask1, parser.Results.mask2) - obj;
        end
        
        
        function obj = whitetophat(obj, mask1, varargin)
            %% Perform morphological white tophat
            %
            % obj = obj.whitetophat(ones(3,3))
            % obj = obj.whitetophat(ones(3,3), ones(5,5))
            % obj = obj.whitetophat(ones(3,3), ones(5,5), ones(1,1))
            % obj = obj.whitetophat(ones(3,3), ones(5,5), ones(1,1), ones(7,7))
            %
            % Input parameters:
            %
            % Output parameters:
            %
            % Description:
            %
            % See also blacktophat
            
            narginchk(2, 3);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'whitetophat', 'obj'));
            
            parser.addRequired('mask1', @(x) validateattributes( x, {'numeric'}, ...
                {'2d', 'nonsparse', 'nonempty'}, 'whitetophat', 'mask1', 2) );
            
            parser.addOptional('mask2', mask1, @(x) validateattributes( x, ...
                {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, 'whitetophat', ...
                'mask2', 3) );
            
            parser.parse(obj, mask1, varargin{:});

            obj = obj - opening(obj, mask1, parser.Results.mask2);
        end
        
        
        function obj = selfdualtophat(obj, mask1, varargin)
            %% Perform morphological self dual tophat
            %
            % obj = obj.selfdualtophat(ones(3,3))
            % obj = obj.selfdualtophat(ones(3,3), ones(5,5))
            % obj = obj.selfdualtophat(ones(3,3), ones(5,5), ones(1,1))
            % obj = obj.selfdualtophat(ones(3,3), ones(5,5), ...
            %                          ones(1,1), ones(7,7))
            %
            % Input parameters:
            %
            % Output parameters:
            %
            % Description:
            %
            % See also whitetophat, blacktophat
            
            narginchk(2, 5);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'selfdualtophat', 'obj'));
            
            parser.addRequired('mask1', @(x) validateattributes( x, {'numeric'}, ...
                {'2d', 'nonsparse', 'nonempty'}, ...
                'selfdualtophat', 'mask1', 2) );
            
            parser.addOptional('mask2', mask1, @(x) validateattributes( x, ...
                {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, ...
                'selfdualtophat', 'mask2', 3) );
            
            parser.addOptional('mask3', mask1, @(x) validateattributes( x, ...
                {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, ...
                'selfdualtophat', 'mask3', 3) );
            
            parser.addOptional('mask4', mask1, @(x) validateattributes( x, ...
                {'numeric'}, {'2d', 'nonsparse', 'nonempty'}, ...
                'selfdualtophat', 'mask4', 3) );
            
            parser.parse(obj, mask1, varargin{:});

            % TODO: really +?
            obj = whitetophat(obj, mask1, parser.Results.mask2) + ...
                blacktophat(obj, parser.Results.mask3, parser.Results.mask4);
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
            %
            % See also maxfilter, minfilter, meanfilter
            
            narginchk(2, 2);
            nargoutchk(0, 1);
            % builtin median function cannot handle nans.
            obj = obj.Scalarfilter(mask, @nanmedian);
        end
        
        %% Other filters
        
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
            %
            % See also medianfilter, maxfilter, minfilter

            narginchk(2, 2);
            nargoutchk(0, 1);
            % builtin mean function cannot handle nans.
            obj = obj.Scalarfilter(mask, @nanmean);
        end
        
        %% Error measures
        
        function val = mse(obj, obj2)
            %% Compute mean squared error
            %
            % val = obj.mse(obj2)
            %
            % Returns squared euclidean distance divided by number of pixels.
            %
            % See also psnr
            
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
        
        
        function val = psnr(obj, obj2)
            %% Compute peak signal to noise ratio
            %
            % val = obj.psnr(obj2)
            %
            % See also mse
            
            narginchk(2, 2);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'mse', 'obj'));
            parser.addRequired('obj2', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'mse', 'obj2'));
            
            parser.parse(obj, obj2);
            if ((obj.rangeMax == obj2.rangeMax) && ...
                    (obj.rangeMax == obj2.rangeMax))
                val = 10.0 * log10(obj.rangeMax/mse(obj, obj2));
            else
                MExc = ExceptionMessage('BadArg', 'message', ...
                    'Images have different ranges.');
                error(MExc.id, MExc.message);
            end
        end
    end
    
end

