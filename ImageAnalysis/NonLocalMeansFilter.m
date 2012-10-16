function out = NonLocalMeansFilter(in,r,sig_g,its)

S = size(in)+4*r;
M = S(1);
N = S(2);
% We do need the double window size as dummy boundary since we will work with
% all the neighborhoods in the neighborhood of a pixel.
out = MirrorEdges(in, 2*[r r]);

[rr cc] = meshgrid(-r:r,-r:r);
for i = 1:its
    for n = 1+2*r:N-2*r
        for m = 1+2*r:M-2*r
            % Get all the neighborhoods around pixel (m,n)
            NN = arrayfun(@(x,y) out(x+(-r:r)+m,y+(-r:r)+n), cc, rr, ...
                'UniformOutput',false);
            % Get central window
            win = out(m+(-r:r),n+(-r:r));
            % Compute the distances between the neighborhoods.
            D = cellfun(@(x) exp(-norm(x(:)-win(:),2)^2/(2*sig_g^2)), NN);
            % Weight pixels and sum up.
            out(m,n) = D(:)'*win(:) / sum(D(:));
        end
    end
    % Update the mirrored edges, so that they stay in sync with the image. If we
    % don't do this, there might appear some artifacts around the boundaries.
    out = MirrorEdges(out(2*r+1:N-2*r,2*r+1:M-2*r),2*[r r]);
end
% Return inner part of the image.
out = out(2*r+1:N-2*r,2*r+1:M-2*r);
end
