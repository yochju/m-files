%M = LaplaceM(256,256,'optsC',struct('boundary','Dirichlet'),'optsR',struct('boundary','Dirichlet'));
%[nr nc vp rp cp] = Sparse2CCM(M);

% Copyright 2013 Laurent Hoeltgen <laurent.hoeltgen@gmail.com>, Martin Schmidt
% <schmidt@mia.uni-saarland.de>
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

% Usage Example.
% >> osmosis2mat
% >> A=CCM2Sparse(nx*nx,ny*ny,v,rp,cp);
% >> B=mean(trui); B=B(:);
% >> for i=1:20000  B=A*B; end;
% >> imshow( uint8(reshape(B,256,256)) ) 

%%
nx=256;%3
ny=256;%4
I = ones(nx,ny);
J = reshape([1:nx*ny]',nx,ny);
U = ImagePad( I, 'left', nan(nx,1), 'right', nan(nx,1), 'top', nan(1,ny), ...
    'bottom', nan(1,ny), 'uleft', nan, 'uright', nan, 'bleft', ...
    nan, 'bright', nan);
D = im2col(U,[3 3],'sliding');
S = zeros(9,nx*ny);%repmat([0 1 0 1 -4 1 0 1 0]',1,nx*ny);
[dp0 dm0 d0p d0m] = canonicalOsmoticities(double(trui));
 for i = 1:nx
     for j =1:ny
         t = zeros(3,3);
         
         if( i<ny )
            %Q(maps(i  ,j,nx,ny), maps(i+1,j,nx,ny)) 
           %t(3,2) = dm0(i+2,j+1);            
            %Q(maps(i+1,j,nx,ny), maps(i  ,j,nx,ny)) = 
            t(3,2)=dp0(i+1,j+1);
         end
         if( j> 1 )
            %Q(maps(i,j  ,nx,ny), maps(i,j-1,nx,ny)) 
           % t(2,1) = d0p(i+1,j  );   
            %Q(maps(i,j-1,nx,ny), maps(i,j  ,nx,ny)) = 
            t(2,1)=d0m(i+1,j+1);
         end
         if( i>1 )
            %Q(maps(i  ,j,nx,ny), maps(i-1,j,nx,ny)) 
           %t(1,2) = dp0(i  ,j+1);
            %Q(maps(i-1,j,nx,ny), maps(i,j  ,nx,ny)) = 
            t(1,2)=dm0(i+1,j+1);
         end
         if( j<nx )
            %Q(maps(i,j  ,nx,ny), maps(i,j+1,nx,ny)) 
            %t(2,3) = d0m(i+1,j+2);
            %Q(maps(i,j+1,nx,ny), maps(i,j  ,nx,ny)) = 
            t(2,3)=d0p(i+1,j+1);
         end
         t=t/10.0;
         t(2,2)=1-sum(t(:));
         
         S(:,(j-1)*ny+i)= t(:);
     end
 end

S2 = repmat([1:9]',1,nx*ny)-4;
R = D.*S;
R2 = D.*S2;
for i = 1:nx*ny
    for j=1:9
    R2(j,i) = R2(j,i)+(i-1)+floor((j-1)/3-1)*(nx-3);
    end
end
C1 = sum(D==1);
cp = cumsum([1 C1]);
v = R(:);
v(isnan(v)) = [];
rp = R2(:);
rp(isnan(rp)) = [];
%%
%full(CCM2Sparse(nx*ny,nx*ny,v,rp,cp))




