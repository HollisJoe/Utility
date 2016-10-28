function []=heat_mapped_matches(im1, im2, x1, x2, display_name1, display_name2)

figure, imshow(im1+100);
[row, col,h]=size(im1);
scale=row*col/(480*640);

C=[cat(1, x1(1:2,:), zeros(1, size(x1,2)))];
C(1,:)=C(1,:)/max(C(1,:));
C(2,:)=C(2,:)/max(C(2,:));

hold on
scatter(x1(1,:)',x1(2,:)', 1*scale, C', 'fill');
hold off
if nargin>4 
    saveas(gcf,['tmp/' display_name1]);    
        
end;


figure, imshow(im2+100);
[row, col,h]=size(im2);
scale=row*col/(480*640);


hold on
scatter(x2(1,:)',x2(2,:)', 1*scale, C', 'fill');
hold off;

if nargin>5 
    saveas(gcf,['tmp/' display_name2]);    
        
end;