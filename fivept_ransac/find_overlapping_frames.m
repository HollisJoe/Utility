function [overlaps]=find_overlapping_frames(vertex, pose, K, row, col, percent)

num_cams=size(pose,3);

overlaps=cell(num_cams,1);

for i=1:num_cams
    i
    index=zeros(num_cams,1);
    [mask1]=vertex_inframe(vertex, pose(:,:,i), K, row, col);
    num_vert=nnz(mask1);
    
    for j=1:num_cams
        [mask2]=vertex_inframe(vertex, pose(:,:,j), K, row, col);
        num_overlap=nnz(mask1 & mask2);
%         j
%         num_overlap/num_vert
        if num_overlap/num_vert>percent
            index(j)=1;
        end;        
    end;
    overlaps{i}=find(index);
    %return;
end;


    

end

function [mask]=vertex_inframe(vertex, pose, K, row, col)
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