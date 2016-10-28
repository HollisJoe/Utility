addpath('toolbox_graph\toolbox_graph');
K1=[2759.48 0 1520.69; 0 2764.16 1006.81; 0  0 1];
row=2048;
col=3072;
[vertex,face] = read_ply('C:\Data\gt\castle_large\data\_OUT\meshAvImgCol.ply');
[pose]=N_view_ground_truth([0:29], 'C:\Data\testing\strecha_castle_large\', 3);
overlap=find_overlapping_frames(vertex', pose, K1, row, col,0.3);

data=load('castle_trad.mat','data');
data=data.data;
path_all=load('castle_trad.mat','path_all');
path_all=path_all.path_all;




evaluation_data=struct('rot_error', [], 'trans_error', [], 'pairs', [], 'rot_mag', [], 'trans_mag', []);
num_cams=size(data.m_e,1);
tested=zeros(num_cams, num_cams);
runner=1;
for i=1:  num_cams
    for j=1:length(overlap{i})
        im_test=overlap{i}(j);
         if i~=im_test && tested(i,im_test)==0 && tested(im_test,i)==0
            tested(i, im_test)=1;
            tested(im_test, i)=1;
            
            pairs=sort([i, im_test]);
            [pose_true,s]=center_pose2(pose(:,:,[pairs(1), pairs(2)]), 1);
            R1=pose_true(:,1:3,2);
            T1=pose_true(:,4,2);
            T1=T1/norm(T1);
            
            evaluation_data(runner).pairs=pairs;
            evaluation_data(runner).rot_mag=180*rot_mag(R1)/pi;
            evaluation_data(runner).trans_mag=s;
            
            
            if ~isempty(data.pose{pairs(1), pairs(2)})
                
                im_test
                cat(2, pose_true(:,:,2), data.pose{pairs(1), pairs(2)})
               
                R2=data.pose{pairs(1), pairs(2)}(:,1:3);
                T2=data.pose{pairs(1), pairs(2)}(:,4);
                T2=T2/norm(T2);
                
                rot_error=180*rot_mag(R1'*R2)/pi;
                t_error=acosd(T1'*T2);
                rot_error
                t_error
                evaluation_data(runner).rot_error=rot_error;
                evaluation_data(runner).trans_error=t_error;
               
                runner=runner+1;
                
            else
                runner=runner+1;
            end
            
        end;
        
    end;
end;

% plot_evaluation(evaluation_data, evaluation_data_bf);



%%%%%%%%%%%%%%%%%%%%%%%%
% matching recall evalutaion


for i=1:length(evaluation_data)
    im1=evaluation_data(i).pairs(1);
    im2=evaluation_data(i).pairs(2);
    if ~isempty(data.coord{im1,im2})
        num=size(data.coord{im1,im2}(1:2,:),2);
        ind=data.index{im1,im2};
        [ok, m_e]=remove_points2(data.pose{im1, im2}, data.coord{im1,im2}(1:2,:), data.coord{im1,im2}(3:4,:), [1:num;1:num], eye(3), eye(3), [], [],0);
        ind=ind(ok);
        
        
        [match_data] = match_from_file(path_all, im1, im2);
        all_match=[ match_data.f1(:,match_data.matches_all(1,:));
            match_data.f2(:,match_data.matches_all(2,:))];
        [percent, pass]=corret_matches(vertex', pose(:,:,im1), pose(:,:,im2), K1, row, col, all_match, 0.04);
        
               
        ind_true=find(pass);
        ind_est=data.index{1,2};
        C = intersect(ind_true,ind_est);
        length(ind_true)
        length(C)
        length(C)/length(ind_true)
        
        
        evaluation_data(i).recall= length(C)/length(ind_true);
    else
        evaluation_data(i).recall=0;
    end;
    
    
end;

recall_evaluation(evaluation_data);

% 
% 
% 
% 
% im1=10;
% im2=11;
% [match_data] = match_from_file(path_all, 10, 11);
% 
% 
% all_match=[ match_data.f1(:,match_data.matches_all(1,:));
%  match_data.f2(:,match_data.matches_all(2,:))];
% 
% 
% [percent, pass]=corret_matches(vertex', pose(:,:,im1), pose(:,:,im2), K1, row, col, all_match, 0.04);
% 
% ind_true=find(pass);
% ind_est=data.index{1,2};
% C = intersect(ind_true,ind_est);
% length(ind_true)
% length(C)
% length(C)/length(ind_true)
