function []=heat_mapped_quiver(im1, x1, x2, display_name1)
%addpath('C:\Users\daniel\Documents\MATLAB\dedicated_widebaseline_matching\plot2svg_20120915\plot2svg_20120915');

figure, h=imshow(uint8(im1+100));
[row, col,h]=size(im1);
scale=row*col/(480*640);
C=[cat(1, x1(1:2,:), zeros(1, size(x1,2)))];
min_x=min(C(1,:));
max_x=max(C(1,:));

min_y=min(C(2,:));
max_y=max(C(2,:));

C(1,:)=(C(1,:)-min_x)/(max_x-min_x);
C(2,:)=(C(2,:)-min_y)/(max_y-min_y);
num=length(x1);
q=x1(1,:)-x2(1,:);
p=x1(2,:)-x2(2,:);
n=sqrt(q.^2+p.^2);
q=q./n;
p=p./n;
hold on
%scatter(x1(1,:)',x1(2,:)', 0.7*scale, C', 'fill');
quiver(x1(1,:)',x1(2,:)', q', p','color', [0 0 1]);

%quiver(x1(1,1:10:end)',x1(2,1:10:end)', q(1:10:end), p(1:10:end));

if nargin>3
    % print('-dpdf','-r1000','filename.pdf')
    
%     set(gca, 'Position', get(gca, 'OuterPosition') - ...
%         get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
%     saveas(gcf, 'a', 'pdf');
    
     saveas(gcf,['tmp/' display_name1]);        
end;


return;
