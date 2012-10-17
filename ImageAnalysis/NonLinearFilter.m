function out = NonLinearFilter(Sig,FCell)
%% Generic nonlinear filtering method.

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

% One could do it without this, but then the boundary handling gets messy.
FilterSizes = cellfun(@(x) size(x), FCell, 'UniformOutput',false);
assert(isequal(FilterSizes{:}));

% Check that we have a filer mask for every pixel.
assert(isequal(size(Sig),size(FCell)));

assert(isequal(mod(FilterSizes{1,1},2),ones(size(FilterSizes{1,1}))));
w = (FilterSizes{1,1}-1)/2;
wr = w(1);
wc = w(2);

MSig = MirrorEdges(Sig,[wr wc]);
[nr nc] = size(MSig);

out = nan(size(Sig));
for r = (1+wr):(nr-wr)
    for c = (1+wc):(nc-wc)
        out(r-wr,c-wc) = conv2( ...
            MSig((r-wr:r+wr),(c-wc:c+wc)) , FCell{r-wr,c-wc} , 'valid');
    end
end

end
