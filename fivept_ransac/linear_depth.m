function [X]=linear_depth(P, x)

num_cameras=size(P,3);
num_pts=size(x,2);

A=zeros(2*num_cameras,4);
X=zeros(4, num_pts);
for i=1:num_pts
    for j=1:num_cameras
        A(j,:)=x(1,i,j)*P(3,:,j)-P(1,:,j);
        A(num_cameras+j,:)=x(2,i,j)*P(3,:,j)-P(2,:,j);
    end;
    [u,s,v]=svd(A);
    X(:,i)=v(:,end);
end;


X(1,:)=X(1,:)./X(4,:);
X(2,:)=X(2,:)./X(4,:);
X(3,:)=X(3,:)./X(4,:);
X(4,:)=1;


