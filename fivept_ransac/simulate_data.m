function [data]= simulate_data()
num_pts=100;
num_views=3;

pts=rand(4, num_pts);
pts(1:2,:)=pts(1:2,:)-0.5;
pts(3,:)=pts(3,:)+10;
pts(4,:)=1;


data=struct('all_matches', [], 'coord', [], 'index', []);
data.all_matches=cell(num_views, num_views);
data.coord=cell(num_views, num_views);
data.pose=cell(num_views, num_views);
data.index=cell(num_views, num_views);

pose=zeros(3,4, num_views);
for i=1:num_views
    pose(1:3,1:3,i)=rotaa(rand()/10, rand()/10, rand()/10);
    pose(:,4,i)=[rand();rand();rand()];
end;

for i=1:num_views
    for j=i+1:num_views
        data.all_matches{i,j}=[1:num_pts; 1:num_pts];
        data.index{i,j}=[1:num_pts];
        xy1=pose(:,:,i)*pts;
        xy1(1,:)=xy1(1,:)./xy1(3,:);
        xy1(2,:)=xy1(2,:)./xy1(3,:);
        xy2=pose(:,:,j)*pts;
        xy2(1,:)=xy2(1,:)./xy2(3,:);
        xy2(2,:)=xy2(2,:)./xy2(3,:);
        
        data.coord{i,j}=cat(1, xy1(1:2,:), xy2(1:2,:));
        pose_est=iterative_2_view(xy1, xy2, [1:num_pts; 1:num_pts], [1:num_pts]);
        data.pose{i,j}=pose_est;
    end;
    
end;
