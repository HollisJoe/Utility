function [inliers]=affine_inliers_research2(Vecc, Vec, f1, f2, wx, wy, ax0, ay0, thres_spatial)




[G]=G_compute_fast(Vecc', Vec', 1);
%[G]=G_compute_fast_single(Vecc', Vec', 1);

Ax=G*wx;
Ax(:,1)=Ax(:,1)+ax0(1);
Ax(:,2)=Ax(:,2)+ax0(2);
Ax(:,3)=Ax(:,3)+ax0(3);
Ay=G*wy;
Ay(:,1)=Ay(:,1)+ay0(1);
Ay(:,2)=Ay(:,2)+ay0(2);
Ay(:,3)=Ay(:,3)+ay0(3);

size(Ax)
size(f1)
f1=cat(1, f1, ones(1, size(f1,2)));

x=sum(Ax'.*f1(1:3,:),1);
y=sum(Ay'.*f1(1:3,:),1);

'error'
median(abs(x-f2(1,:)))

% dir=f1(1:2,:);
% dir(1,:)=x-f1(1,:);
% dir(2,:)=y-f1(2,:);
% 
% dir2=dir;
% dir2(1,:)=f2(1,:)-f1(1,:);
% dir2(2,:)=f2(2,:)-f1(2,:);
% 
% dir=cat(1, dir, 0.1*ones(1,size(dir,2)));
% dir=matrix_norm(dir);
% 
% dir2=cat(1, dir2, 0.1*ones(1,size(dir2,2)));
% dir2=matrix_norm(dir2);
% 
% dir_e=sum(dir.*dir2,1);
% dir_e=acosd(abs(dir_e));
% % 
% % dir_e=acosd(abs(dir*dir2));
%  dir_e(1:10)
% 
% 'angle_error'
% length(dir_e)
% max(abs(dir_e))
% sum(abs(dir_e)>10)
% mask_dir=dir_e<2;


error=((x-f2(1,:)).^2+(y-f2(2,:)).^2);
% error
% size(error)

mask=error< thres_spatial;
inliers=find(mask);


