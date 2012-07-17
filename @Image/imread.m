function varargout = imread(varargin)
%IMREAD reads an image file.
%   This is wrapper function for the builtin imread function. It uses the same
%   calling structure but instead of returning a matrix, it returns an Image
%   object. Padding is set to 0. Note that this is a static class method.
%
%   See also imread, imwrite
error(nargoutchk(0,2,nargout));
switch nargout
    case 0
        ExcM = ExceptionMessage( ...
            'NumArg', ...
            'No output arguments have been specified.');
        warning(ExcM.id,ExcM.message);
    case 1
        pixel = imread(varargin{:});
        varargout(1) = {Image(im2double(pixel),[0 0 0 0])};
    case 2
        [pixel map] = imread(varargin{:});
        varargout(1) = {Image(im2double(pixel),[0 0 0 0])};
        varargout(2) = {map};
end
end