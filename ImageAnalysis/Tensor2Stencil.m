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

% Last revision on: 2013-07-08 17:30

%% Notes

% Implements the discretisation from:
%
% J. Weickert, K. Hagenburg, M. Breuß, O. Vogel:
% Linear osmosis models for visual computing.
% In A. Heyden, F. Kahl, C. Olsson, M. Oskarsson, X.-C. Tai (Eds.):
% Energy Minimization Methods in Computer Vision and Pattern Recognition.
% Lecture Notes in Computer Science, Vol. 8081, 26-39, Springer, Berlin, 2013

% TODO: b = 0 should yield the same results as for IsoDiffStencil. Check this.

%% Parse input and output.

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
