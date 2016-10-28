function [index_final,all_matches, x1, x2, m_e, pose]=pose_matcher_save(path_all,  ind1,   ind2, K1, K2)
thres_spatial=0.01;
% 
% K1=[3860.67 0 2592; 0 3860.67 1728; 0  0 1]; %hdb
% K2=[3860.67 0 2592; 0 3860.67 1728; 0  0 1];

% K1=[2270.90 0 2592; 0 2270.90 1728; 0  0 1];
% K2=[2270.90 0 2592; 0 2270.90 1728; 0  0 1]; %board
% 
%  K1=[2018 0 960;    0 2018 640; 0  0 1];
%  K2=[2018 0 960;   0 2018 640; 0  0 1]; %uiuc

% 
%  K1=[600 0 480;    0 600 270; 0  0 1];
%  K2=[600 0 480;    0 600 270; 0  0 1]; %sengkange


%  K1=[4087.75 0 2592;    0 4087.75 1728; 0  0 1];
%  K2=[4087.75 0 2592;    0 4087.75 1728; 0  0 1]; %borad, adsc comp
K1_i=inv(K1);
K2_i=inv(K1);

pix_length=1;

[match_data] = match_from_file(path_all, ind1, ind2);


image1=imread(path_all(ind1).path);
image2=imread(path_all(ind2).path);
res=max(size(image1));
res=max([size(image2),res]);
d_scale=10*res/640;



[match_final, index_main, index_sub]=nova_new_form(match_data, thres_spatial, d_scale, image1, image2);



[f1]=calib_data(match_final.f1(1:2,:), K1_i);
[f2]=calib_data(match_final.f2(1:2,:), K2_i);


[pose, F]=pose_simple(f1, f2, match_final.matches_all(:,index_main), eye(3), eye(3),0.001);
close all

pose
'so many pts'
length(index_sub)

[ind, m_e]=remove_points2(pose, f1, f2, match_final.matches_all(:,index_main), eye(3), eye(3), image1, image2,0);
index_main=index_main(ind); % recent addtion
m_e
%return;

m_e=min(m_e, 3*pix_length);
close all

index_sub_final=index_sub;
for k=1:length(index_sub)
    %ind_potential=remove_points(pose, f1, f2, match_final.matches_all(:,index_sub(k).index), 0.03, eye(3), eye(3), image1, image2,0);
    
    %if length(ind_potential) >10
    if length(index_sub(k).index)>10
        index_tmp=cat(1, index_main, index_sub(k).index);
        
        max_found=0;
        ind_cat=[];
        ind_small=[];
        
        for kk=1:1
            
            %[ind_p]=ransac_inliers(f1, f2, match_final.matches_all(:,index_tmp), eye(3), eye(3), 2*1.48*m_e);
            [ind_p]=ransac_subsample(f1, f2, match_final.matches_all(:,index_tmp), eye(3), eye(3), 2*1.48*m_e);
            
            ind=ind_p;
            match_data_sub=match_final;
            ind_found= intersect(index_sub(k).index,index_tmp(ind));
            match_data_sub.ind_chosen=ind_found;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             match_data_sub.ind_final=ind_found;
            %             display_match_struc(uint8(image1), uint8(image2), match_data_sub);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            num_needed=floor(0.2*length(match_data_sub.ind_chosen));
            num_needed=min(length(ind), num_needed);
            ind_=ind(randsample(length(ind), num_needed));
            match_data_sub.ind_chosen=cat(1, match_data_sub.ind_chosen, index_tmp(ind_));
            %[match_data_sub]=filter_stricter(match_data_sub, thres_spatial);
            [match_data_sub]=filter_strict(match_data_sub, thres_spatial);

            % [match_data_sub]=filter_fast(match_data_sub, thres_spatial);
            
            
            ind=unique(cat(1,match_data_sub.ind_final, index_main));
            
            if length(ind)>max_found
                max_found=length(ind);
                ind_small=match_data_sub.ind_final;
                ind_cat=ind;
            end;
            if length(ind_small)>0.8*length(index_sub(k).index) %good enough
                break;
            end;
            
        end;
        
        
       try
            [pose_b, F]=pose_economy(f1, f2, match_final.matches_all(:,ind_cat), eye(3), eye(3), 2*1.48*m_e);
            [~, m_t]=remove_points2(pose_b, f1, f2, match_final.matches_all(:,ind_small), eye(3), eye(3), image1, image2,0);
            
            index_sub_final(k).index=ind_small;
            index_sub_final(k).m_t=m_t;
        catch
            index_sub_final(k).index=[];
            index_sub_final(k).m_t=100000;
        end;
        
        
        
        %display_match_struc(uint8(image1), uint8(image2),match_final);
        
        
    else
        index_sub_final(k).index=[];
    end;
end;

index_final=index_main;
%index_final=[];
for k=1:length(index_sub_final)
    if ~isempty(index_sub_final(k).index) && index_sub_final(k).m_t< 3*1.48*m_e
        index_final=cat(1, index_final,index_sub_final(k).index);
    end;
end;
index_final=unique(index_final);
match_final.ind_final=index_final;
%match_final.ind_final=index_sub_final(7).index;
display_match_struc(uint8(image1), uint8(image2),match_final);

pose_old=pose;

%[pose, F]=pose_simple(f1, f2, match_final.matches_all(:,index_final), eye(3), eye(3),0.001);

%pose=iterative_2_view(f1, f2, match_final.matches_all, index_final);
% 
% [pose,distort]=pose_est_sing(f1, f2, match_final.matches_all(:, index_final), eye(3), eye(3),0.001);
% if distort==0
    pose=iterative_2_view(f1, f2, match_final.matches_all, index_final);
%end;

pose_old
pose

% [Z, s_e, problem]=confidence10(pose, f1(:, match_final.matches_all(1, index_final)),  f1(:, match_final.matches_all(1, index_final)), 1);
% Z

[ok, m_e]=remove_points2(pose, f1, f2, match_final.matches_all(:, index_final), K1, K2, image1, image2,1);
% pose_t=[pose(1:3,1:3)', -pose(1:3,1:3)'*pose(1:3,4)];
% match_final_t=match_final;
% match_final_t.matches_all=match_final.matches_all([2 1], :);
% [ok, m_e_t]=remove_points2(pose_t, f2, f1, match_final_t.matches_all(:, index_final), K1, K2, image2, image1,1);
% m_e_t
m_e


index_final=index_final(ok);
x1=f1(1:2, match_final.matches_all(1,index_final));
x2=f2(1:2, match_final.matches_all(2,index_final));

imwrite(image1, ['tmp\im', num2str(ind1), '.png']);
imwrite(image2, ['tmp\im', num2str(ind2), '.png']);
heat_mapped_matches(image1, image2, K1*cat(1, x1,ones(1, size(x1,2))), K2*cat(1, x2,ones(1, size(x2,2))), ['ours_',num2str(ind1), '_', num2str(ind2), 'a.png'], ['ours_',num2str(ind1), '_', num2str(ind2), 'b.png'])


all_matches=match_final.matches_all;

