function []=heat_mapped_gt(im1, im2, x1, x2, pass,  display_name1, display_name2)

figure, imshow(im1);
[row, col,h]=size(im1);
scale=1*row*col/(480*640);
%C=[cat(1, x1(1:2,:), zeros(1, size(x1,2)))];
C=[cat(1, x1(1:2,:), zeros(1, size(x1,2)))];
min_x=min(C(1,:));
max_x=max(C(1,:));

min_y=min(C(2,:));
max_y=max(C(2,:));

C(1,:)=(C(1,:)-min_x)/(max_x-min_x);
C(2,:)=(C(2,:)-min_y)/(max_y-min_y);

hold on
xa=x1;
xa(:,pass)=[];
xb=x2;
xb(:,pass)=[];
C_b=zeros(3, size(xa,2));
scatter(xa(1,:)',xa(2,:)', 1*scale, C_b', 'fill');
scatter(x1(1,pass)',x1(2,pass)', 1*scale, C(:,pass)', 'fill');

if nargin>5 
    saveas(gcf,['tmp/' display_name1]);            
end;
hold off;

figure, imshow(im2);
[row, col,h]=size(im2);
scale=1*row*col/(480*640);


hold on
scatter(xb(1,:)',xb(2,:)', 1*scale, C_b', 'fill');
scatter(x2(1,pass)',x2(2,pass)', 1*scale, C(:,pass)', 'fill');

if nargin>6 
    saveas(gcf,['tmp/' display_name2]);    
        
end;

hold off;