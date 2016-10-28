%function [Z, se, problem, pose_final,x1, x2, x1_core, x2_core]=pose_matcher_fundamental(path_all,  ind1,   ind2)
thres_spatial=0.01;
K1_i=eye(3);
K2_i=eye(3);
K1=eye(3);
K2=eye(3);
pix_length=1;

[match_data] = match_from_file(path_all, ind1, ind2);


image1=imread(path_all(ind1).path);
image2=imread(path_all(ind2).path);
res=max(size(image1));
res=max([size(image2),res]);
d_scale=10*res/640;



[match_final, index_main, index_sub]=nova_new_form(match_data, thres_spatial, d_scale, image1, image2);

[f1]=match_final.f1(1:2,:);
[f2]=match_final.f2(1:2,:);



[fLMedS, ~] = estimateFundamentalMatrix(...
    f1(1:2, match_final.matches_all(1,index_main))', f2(1:2, match_final.matches_all(2,index_main))', ...
    'Method', 'RANSAC', 'NumTrials', 2000, 'DistanceThreshold', 1e-4);
[~, m_e]=remove_points2(fLMedS, f1, f2, match_final.matches_all(:,index_main), eye(3), eye(3), image1, image2,1);


% [f1]=calib_data(match_final.f1(1:2,:), K1_i);
% [f2]=calib_data(match_final.f2(1:2,:), K2_i);
% 
% 
% [pose, F]=pose_simple(f1, f2, match_final.matches_all(:,index_main), eye(3), eye(3),0.001);
close all


'so many pts'
length(index_sub)

%[~, m_e]=remove_points2(pose, f1, f2, match_final.matches_all(:,index_main), eye(3), eye(3), image1, image2,0);


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
%             [fLMedS, ~] = estimateFundamentalMatrix(...
%                 f1(1:2, match_final.matches_all(1,index_tmp))', f2(1:2, match_final.matches_all(2,index_tmp))', 'NumTrials', 2000);
             [fLMedS, ~] = estimateFundamentalMatrix(...
                f1(1:2, match_final.matches_all(1,index_tmp))', f2(1:2, match_final.matches_all(2,index_tmp))', ...
             'Method', 'RANSAC', 'NumTrials', 2000, 'DistanceThreshold', 1e-4);
         
            [ind_p, ~]=remove_points2(fLMedS, f1, f2, match_final.matches_all(:,index_tmp), eye(3), eye(3), image1, image2,1);


            %[ind_p]=ransac_subsample(f1, f2, match_final.matches_all(:,index_tmp), eye(3), eye(3), 2*1.48*m_e);
            
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
        
        
       % try
%             [fLMedS, ~] = estimateFundamentalMatrix(...
%                 f1(1:2, match_final.matches_all(1,ind_cat))', f2(1:2, match_final.matches_all(2,ind_cat))', 'NumTrials', 2000);
            
              [fLMedS, ~] = estimateFundamentalMatrix(...
                f1(1:2, match_final.matches_all(1,ind_cat))', f2(1:2, match_final.matches_all(2,ind_cat))', ...
             'Method', 'RANSAC', 'NumTrials', 2000, 'DistanceThreshold', 1e-4);
            %[pose_b, F]=pose_economy(f1, f2, match_final.matches_all(:,ind_cat), eye(3), eye(3), 2*1.48*m_e);
            [~, m_t]=remove_points2(fLMedS, f1, f2, match_final.matches_all(:,ind_small), eye(3), eye(3), image1, image2,1);
            
            
            index_sub_final(k).index=ind_small;
            index_sub_final(k).m_t=m_t;
%         catch
%             index_sub_final(k).index=[];
%             index_sub_final(k).m_t=100000;
%         end;
%         
        
        
        %display_match_struc(uint8(image1), uint8(image2),match_final);
        
        
    else
        index_sub_final(k).index=[];
    end;
end;

%index_final=index_main;
index_final=[];
for k=1:length(index_sub_final)
    'sub cluster'
    index_sub_final(k).m_t
    m_e
    if ~isempty(index_sub_final(k).index) % && index_sub_final(k).m_t< 3*1.48*m_e
        index_final=cat(1, index_final,index_sub_final(k).index);
        
        match_final.ind_final=index_sub_final(k).index;
        display_match_struc(uint8(image1), uint8(image2),match_final);
    end;   
    
end;



index_final=unique(index_final);
match_final.ind_final=index_final;
%match_final.ind_final=index_sub_final(7).index;
display_match_struc(uint8(image1), uint8(image2),match_final);

k=donk


%[pose, F]=pose_simple(f1, f2, match_final.matches_all(:,index_final), eye(3), eye(3),0.001);

%pose=iterative_2_view(f1, f2, match_final.matches_all, index_final);
% 
% [pose,distort]=pose_est_sing(f1, f2, match_final.matches_all(:, index_final), eye(3), eye(3),0.001);
% if distort==0
    pose=iterative_2_view(f1, f2, match_final.matches_all, index_final);
%end;

pose
[~, m_e]=remove_points2(pose, f1, f2, match_final.matches_all(:, index_final), K1, K2, image1, image2,1);
x1=f1(1:2, match_final.matches_all(1,index_final));
x2=f2(1:2, match_final.matches_all(2,index_final));
pose_final=pose;
problem=0;
Z=10;
se=0;

x1_core=f1(1:2, match_final.matches_all(1,index_main));
x2_core=f2(1:2, match_final.matches_all(2,index_main));
