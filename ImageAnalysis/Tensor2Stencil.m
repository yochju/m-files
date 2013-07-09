function [out] = Tensor2Stencil(a, b, c, alpha, beta)
%% Tensor2Stencil
%
% [out] = Tensor2Stencil(a, b, c, alpha, beta)
%
% Input parameters (required):
%
% a: entry (1,1) of the diffusion tensor. double array.
% b: entry (1,2) and (2,1) of the diffusion tensor. double array.
% c: entry (2,2) of the diffusion tensor. double array.
% alpha : model parameter. double array.
% beta : model parameter. double array.
%
% Input parameters (parameters):
%
% Parameters are either struct with the following fields and corresponding
% values or option/value pairs, where the option is specified as a string.
%
% -
%
% Input parameters (optional):
%
% The number of optional parameters is always at most one. If a function takes
% an optional parameter, it does not take any other parameters.
%
% -
%
% Output parameters:
%
% -
%
% Output parameters (optional):
%
% -
%
% Description:
%
% Computes the stencil to the diffusion tensor [a b ; b c]. The tensor entries
% can be spatially variant. The same holds for the model parameters alpha and
% beta. Setting alpha = beta = 0 yields a standard discretisation. Other choices
% are alpha = 0 and beta = sgn(b), alpha = 0.5 and beta = 0 or alpha = 0.44 and
% beta = 0.118*sgn(b).
%
% Example:
%
% -
%
% See also IsoDiffStencil

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Last revision on: 2013-07-09 14:00

%% Notes

% Implementation is based on the following paper:
%
% L^2-Stable Nonstandard finite Differences for Anisotropic Diffusion
% Joachim Weickert, Martin Welk, Marco Wickert
% In A. Kuijper, K. Bredies, T. Pock, H. Bischof (Eds.): Scale Space and
% Variational Methods in Computer Vision: Lecture Notes in Computer Science,
% Vol. 7893, pp. 380-391, Springer, Berlin, 2013
% DOI: 10.1007/978-3-642-38267-3_32
% Print ISBN: 978-3-642-38266-6
% Online ISBN: 978-3-642-38267-3
% Also available at:
% http://www.mia.uni-saarland.de/Publications/weickert-ssvm13.pdf

% TODO: b = 0 should yield the same results as for IsoDiffStencil. Check this.

%% Parse input and output.

narginchk(5,5);
nargoutchk(0,1);

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.StructExpand = true;

parser.addRequired('a', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d'}, mfilename, 'a', 1));

parser.addRequired('b', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d', 'size', size(a)}, mfilename, 'b', 1));

parser.addRequired('c', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d', 'size', size(a)}, mfilename, 'c', 1));

parser.addRequired('alpha', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d', 'size', size(a)}, mfilename, 'alpha', 1));

parser.addRequired('beta', @(x) validateattributes(x, {'numeric'}, ...
    {'nonempty','finite','2d', 'size', size(a)}, mfilename, 'beta', 1));

parser.parse( a, b, c, alpha, beta);

%% Run code.

out = cell(3,3);

out{1,1} = InterPixelValue((beta-1).*b + alpha.*(a+c),-1, 1);

out{1,2} = InterPixelValue(((1-alpha).*c - alpha.*a + beta.*b), 1, 1) + ...
    InterPixelValue(((1-alpha).*c - alpha.*a + beta.*b),-1, 1);

out{1,3} = InterPixelValue((beta+1)*b + alpha*(a+c), 1, 1);


out{2,1} = InterPixelValue(((1-alpha).*c - alpha.*a + beta.*b),-1, 1) + ...
    InterPixelValue(((1-alpha).*c - alpha.*a + beta.*b),-1,-1);

out{2,2} = - ( ...
    InterPixelValue(((1-alpha).*(a+c) - (beta-1).*b), 1, 1) + ...
    InterPixelValue(((1-alpha).*(a+c) - (beta+1).*b), 1,-1) + ...
    InterPixelValue(((1-alpha).*(a+c) - (beta+1).*b),-1, 1) + ...
    InterPixelValue(((1-alpha).*(a+c) - (beta-1).*b),-1,-1) );

out{2,3} = InterPixelValue(((1-alpha).*c - alpha.*a + beta.*b), 1, 1) + ...
    InterPixelValue(((1-alpha).*c - alpha.*a + beta.*b), 1,-1);


out{3,1} = InterPixelValue((beta+1).*b + alpha.*(a+c),-1,-1);

out{3,2} = InterPixelValue(((1-alpha).*c - alpha.*a + beta.*b), 1,-1) + ...
    InterPixelValue(((1-alpha).*c - alpha.*a + beta.*b),-1,-1);

out{3,3} = InterPixelValue((beta-1).*b + alpha.*(a+c), 1,-1);

end

function out = InterPixelValue(in, xshift, yshift)
%% Perform linear interpolation inbetween two pixels.

[nr, nc] = size(in);
[X Y] = meshgrid(1:nc, 1:nr);

% Perform the interpolation step. The variables xshift and yshift should contain
% the values +1 or -1 depending on whether the next or the previous pixel should
% be considered. Note that this fills entries outside of the domain with NaN.
out = interp2(X,Y,Z,X+xshift/2,X+yshift/2,'linear');

% Use Neumann bounday conditions to get the missing values. Note that mirroring
% implies that linear interpolation doesn't change the value.
if xshift == -1
    out(:, 1) = in(:, 1);
elseif xshift == 1
    out(:, end) = in(:, end);
else
    ExcM = ExceptionMessage('Input', 'message', ...
        'Bad shift specified.');
    error(ExcM.id, ExcM.message);
end
if yshift == -1
    out(1, :) = in(1, :);
elseif yshift == 1
    out(end, :) = in(end, :);
else
    ExcM = ExceptionMessage('Input', 'message', ...
        'Bad shift specified.');
    error(ExcM.id, ExcM.message);
end

end