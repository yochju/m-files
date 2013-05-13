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

nr = 4;
nc = 4;
N = nr*nc;
u11 = 9*ones(N,1);
u12 = 8*ones(N,1);
u13 = 7*ones(N,1);

u21 = 6*ones(N,1);
u22 = 5*ones(N,1);
u23 = 4*ones(N,1);

u31 = 3*ones(N,1);
u32 = 2*ones(N,1);
u33 = 1*ones(N,1);
%%
I = ones(nr,nc);
J = reshape([1:N]',nr,nc);
U = ImagePad( I, 'left', nan(nr,1), 'right', nan(nr,1), 'top', nan(1,nc), ...
    'bottom', nan(1,nc), 'uleft', nan, 'uright', nan, 'bleft', ...
    nan, 'bright', nan);
D = im2col(U,[3 3],'sliding');
S = [ u11' ; u12' ; u13' ; u21' ; u22' ; u23' ; u31' ; u32' ; u33' ];
R = D.*S;
S2 = repmat([1:9]',1,N)-4;
R2 = D.*S2;
for i = 1:N
    for j=1:9
    R2(j,i) = R2(j,i)+(i-1)+floor((j-1)/3-1)*(nr-3);
    end
end
C1 = sum(D==1);
cp = cumsum([1 C1]);
v = R(:);
v(isnan(v)) = [];
rp = R2(:);
rp(isnan(rp)) = [];
full(CCM2Sparse(N,N,v,rp,cp))
