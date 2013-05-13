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

M = LaplaceM(3,4);
[nr nc vp rp cp] = Sparse2CCM(M);
%%
I = ones(3,4);
J = reshape([1:12]',3,4);
U = ImagePad( I, 'left', nan(3,1), 'right', nan(3,1), 'top', nan(1,4), ...
    'bottom', nan(1,4), 'uleft', nan, 'uright', nan, 'bleft', ...
    nan, 'bright', nan);
D = im2col(U,[3 3],'sliding');
S = repmat([0 1 0 1 -4 1 0 1 0]',1,12);
S2 = repmat([1:9]',1,12)-4;
R = D.*S;
R2 = D.*S2;
for i = 1:12
    R2(:,i) = R2(:,i)+(i-1);
end
C1 = sum(D==1);
cp = cumsum([1 C1]);
v = R(:);
v(isnan(v)) = [];
rp = R2(:);
rp(isnan(rp)) = [];
%%
full(CCM2Sparse(12,12,v,rp,cp))
