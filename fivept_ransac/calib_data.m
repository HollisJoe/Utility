function [x1]=calib_data(x1, K_i)

if size(x1,1)==2
     x1=cat(1, x1, ones(1,size(x1,2)));
end;
 x1=K_i*x1;
 x1(1,:)=x1(1,:)./x1(3,:);
 x1(2,:)=x1(2,:)./x1(3,:);
 x1(3,:)=1;

 