function [percent, pass]=matching_error(vertex, pose1, pose2, K, row, col, matches, thres)
%macthes is a 4x N matrix;

a=cat(1, matches(1:2,:), ones(1, size(matches,2)));
b=cat(1, matches(3:4,:), ones(1, size(matches,2)));
a=K*a;
b=K*b;
matches=cat(1, a(1:2,:), b(1:2,:));

[mask1, xy1]=vertex_inframe(vertex, pose1, K, row, col);
[mask2, xy2]=vertex_inframe(vertex, pose2, K, row, col);

mask=mask1&mask2;
gt=cat(1, xy1(1:2,mask), xy2(1:2,mask));

min_dim=min(row, col);

total=size(matches,2);


kdtree = vl_kdtreebuild(gt) ;

[~, distance] = vl_kdtreequery(kdtree, gt, matches(1:4,:), 'MaxComparisons', 15 );


pass=distance<(thres*min_dim)^2;

num_inliers=nnz(pass);
percent=num_inliers/total;

percent

end

function [mask, xy]=vertex_inframe(vertex, pose, K, row, col)
vertex(2:3,:)=-1*vertex(2:3,:);
num_pts=size(vertex, 2);
R=pose(:,1:3);
T=pose(:,4);
points=R*vertex;
points(1,:)=points(1,:)+T(1);
points(2,:)=points(2,:)+T(2);
points(3,:)=points(3,:)+T(3);

x=points(1,:)./points(3,:);
y=points(2,:)./points(3,:);
one=ones(1, num_pts);

xy=K*cat(1, x, y, one);
mask1=xy(1,:)>1 & xy(1,:)< col;
mask2=xy(2,:)>1 & xy(2,:)< row;
mask3=points(3,:)>0;
mask=mask1& mask2 & mask3;

% im=zeros(row, col);
%
% for i=1:length(mask)
%     if mask(i)>0
%         im(round(xy(2,i)), round(xy(1,i)))=1;
%     end;
% end;
%
% figure, imshow(im);
% figure,
% plot3(vertex(1,mask), vertex(2, mask), vertex(3, mask))

end