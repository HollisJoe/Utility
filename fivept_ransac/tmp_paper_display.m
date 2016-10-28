% display bf
% 
% ind1=1;
% ind2=3;
% [matchings, xy1, xy2, image1, image2]=display_pure_bf(path_all, ind1,ind2);
% 
% heat_mapped_gt(image1, image2, xy1(1:2,matchings(1,:)), xy2(1:2,matchings(2,:)), [1:length(matchings)],...
%     ['try_',num2str(ind1), '_', num2str(ind2), 'a.png'], ['try_', num2str(ind1), '_', num2str(ind2), 'b.png'] );

%     x1=cat(1, xy1(1:2,:), ones(1, length(xy1)));
%     x2=cat(1, xy2(1:2,:), ones(1, length(xy2)));
%     x1=inv(K1)*x1;
%     x2=inv(K2)*x2;
%     pose=iterative_2_view(x1, x2, matchings, [1:length(matchings)]);
%     [ok, m_e]=remove_points2(pose, x1, x2, matchings, K1, K2, image1, image2,1);
%     
%     
% 
%     heat_mapped_matches(image1, image2, K1*x1(:,matchings(1,ok)), K2*x2(:, matchings(2,ok)));
% display_match_vec(image1, image2, K1*x1(:,matchings(1,ok)),  K2*x2(:, matchings(2,ok)))
%

% display gt epipolar outlier rejetction
addpath('toolbox_graph\toolbox_graph');
header='ori_';
ind1=1;
ind2=15;

[match_data] = match_from_file(path_all, ind1, ind2);

addpath('toolbox_graph\toolbox_graph');
K1=[2759.48 0 1520.69; 0 2764.16 1006.81; 0  0 1];
row=2048;
col=3072;
[vertex,~] = read_ply('C:\Data\gt\entry\data\_OUT\meshAvImgCol.ply');
[pose]=N_view_ground_truth([0:24], 'C:\Data\asift\castle_large\', 3);
%overlap=find_overlapping_frames(vertex', pose, K1, row, col,0.3);

[index_final,all_matches, x1, x2, m_e, p]=asift_pose(path_all, ind1,ind2, K1, K1);


[pose_true,s]=center_pose2(pose(:,:,[ind1, ind2]), 1);
R1=pose_true(:,1:3,2);
T1=pose_true(:,4,2);
T1=T1/norm(T1);

im1=imread(path_all(ind1).path);
im2=imread(path_all(ind2).path);
matches_all=[1:length(x1);
             1:length(x1)];

% [ok]=remove_points(pose_true(:,:,2), x1(1:2,:),x2(1:2,:), matches_all, K1, K2, im1, im2,1*(2048/480)/2759, 1);
% 
% return;

ok=[1:length(matches_all)];
x1=cat(1,  x1(1:2,:), ones(1, length(matches_all)));
x2=cat(1,  x2(1:2,:), ones(1, length(matches_all)));
a=x1;
b=x2;
coord=cat(1, a(1:2,:),b(1:2,:));
coord=coord(:,ok);
%[percent, pass]=matching_error(vertex', pose(:,:,ind1), pose(:,:,ind2), K1, row, col, coord, 0.04);
a=K1*a;
b=K1*b;
pass=[1:length(a)];
heat_mapped_gt(im1, im2, a(1:2,:), b(1:2,:), pass, [header, 'asift_',num2str(ind1), '_', num2str(ind2), 'a.png'], [header, 'asift_', num2str(ind1), '_', num2str(ind2), 'b.png'] );
%heat_mapped_gt(im1, im2, x1(1:2,ok), x2(1:2,ok), pass, [header, 'epip_',num2str(ind1), '_', num2str(ind2), 'a.png'], [header, 'epip_', num2str(ind1), '_', num2str(ind2), 'b.png'] );

