function out = BilateralFilter(in,r,sig_w,sig_g,its)
%% Performs bilateral filtering with gaussians.

% Copyright 2012 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>
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

% Last revision on: 17.10.2012 07:48

% TODO: improve using http://www.mathworks.nl/help/images/ref/colfilt.html ?

S = size(in)+2*r;
M = S(1);
N = S(2);
out = MirrorEdges(in, [r r]);

% Create spatial weighting mask. Since it doesn't depend on the underlying pixel
% value, it can be computed outside of the loop.
[rr cc] = meshgrid(-r:r,-r:r);
w = exp( -(rr.^2 + cc.^2)./(2*sig_w^2) );

for i = 1:its
    for n = 1+r:N-r
        for m = 1+r:M-r           
            % Get window of size (2r+1)x(2r+1) around (m,n)
            f = out(m+(-r:r),n+(-r:r));
            % Compute tonal weights in pixel (m,n)
            g = exp( -((out(m,n) - f).^2)./(2*sig_g^2) );
            % Weight the neighboring pixels and add up.
            out(m,n) = (g(:).*w(:))'*f(:)/(g(:)'*w(:));
        end
    end
    % Update the mirrored edges, so that they stay in sync with the image. If we
    % don't do this, there might appear some artifacts around the boundaries.
    out = MirrorEdges(out(r+1:N-r,r+1:M-r),[r r]);
end
% Return inner part of the image.
out = out(r+1:N-r,r+1:M-r);
end
