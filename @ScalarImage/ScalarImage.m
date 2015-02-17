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
    
    % Last revision on: 16.02.2015 10:00
    
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
            % Acts as a wrapper function around padarray from the image
            % processing toolbox. Arguments are only checked for their existence
            % and given sane default values if missing. Otherwise everything is
            % left to padarray.
            
            narginchk(1, 7);
            nargoutchk(0, 1);
            
            parser = inputParser;
            
            parser.addRequired('obj', @(x) validateattributes( x, ...
                {'ScalarImage'}, {}, 'pad', 'obj'));
            
            parser.addParameter('padsize', [1, 1]);
            parser.addParameter('padval', 0);
            parser.addParameter('direction', 'both');
                        
            parser.parse(obj, varargin{:});
            
            obj.p = padarray(obj.p, parser.Results.padsize, ...
                parser.Results.padval, parser.Results.direction);
            
            obj.br = obj.br + parser.Results.padsize(1);
            obj.bc = obj.bc + parser.Results.padsize(2);
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
            %% Change image shape.
            
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
        
    end
    
end

