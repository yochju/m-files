function smvp

% Dedicated mex-file for Sparse-Matrix-Vector-Products (smvp)
%
%   x = smvp(A,b);
%
% This function is the same as x = A*b, for sparse A and dense vector input
% b, but is generally much faster.
%
% The speed increase is probably only important for large problems that
% need to be solved repeatedly.
%
% Example:
%
%   g = numgrid('L',250);
%   A = delsq(g);
%   b = ones(size(A,1),1);
%
%   tic
%   for k = 1:20, x = A*b; end 
%   inbuilt = toc
%
%   tic
%   for k = 1:20, x = smvp(A,b); end 
%   mex = toc
%
% See also, *

% Darren Engwirda - 2006.