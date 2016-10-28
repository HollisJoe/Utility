%function [inliers]=likelihood_filter(p1, p2, threshold)
function [match_data, lambda]=likelihood_filter_strict(match_data, global_thres, min_lambda)

matches_all=match_data.matches_all;
ind=match_data.ind_chosen;
problem_mask=match_data.problem_pts(ind);
ind=ind(~problem_mask);

p1=match_data.f1(1:2,matches_all(1,ind));
p2=match_data.f2(1:2,matches_all(2,ind));
aff=match_data.affine_all(:, ind);
threshold=match_data.likelihood_threshold;

num_pts=size(p1,2);
N_=ones(num_pts, 1);

[p_all, T1, T2]=data2points_aff(p1, p2, aff);

num_sample=100;
% if length(p_all)< 300
%     num_sample=size(p_all,2);
% end;
p=cluster_sample(p_all,num_sample);


if length(p_all)> 10000
    ind_s=randsample(length(p_all),10000);
    p_all_sub=p_all(:,ind_s);
    N_=N_(ind_s);
else
    p_all_sub=p_all;
end;

[w,~,~, lambda]=grad_asym_strict(p_all_sub, p, N_,0.1, min_lambda);
% w_s=w;
% lambda_s=lambda;
%[w,lambda]=myfunT(p_all_sub, p, N_,0.1, min_lambda);


%[w,lambda]=myfunT(p_all_sub, p, N_,0.1, min_lambda);

%[G_all_out]=G_compute_gpu(single(p_all), single(p));
[G_all_out]=G_compute_fast_single(p_all,p, 1);

% 
% if lambda <1 && min_lambda~=0
%     global_thres=global_thres/lambda;
%     global_thres
% end;

inliers=find(G_all_out*w>threshold);

match_data.ind_chosen=ind(inliers);


p11=match_data.f1(1:2,matches_all(1,:));
p22=match_data.f2(1:2,matches_all(2,:));
[p_all_ll, T1, T2]=data2points_aff(p11, p22, match_data.affine_all, T1, T2);
%[G_all]=G_compute_gpu(single(p_all_ll), single(p));
[G_all]=G_compute_fast_single(p_all_ll, p, 1);
inliers=find(G_all*w>global_thres);


match_data.ind_likeli=inliers;
match_data.ind_final=inliers;
match_data.T1=T1;
match_data.T2=T2;
% 
% 
% if length(match_data.ind_chosen) <300   
%     match_data.ind_chosen=unique(cat(1, match_data.ind_chosen, ind_store));    
% end;

if length(match_data.ind_chosen) <300
    %     'too few'
    num_needed=300- length(match_data.ind_chosen);
    num_needed=min(num_needed, length(match_data.ind_likeli));
    ind=randsample(length(match_data.ind_likeli), num_needed);
    match_data.ind_chosen=unique(cat(1, match_data.ind_chosen, match_data.ind_likeli(ind)));
end;

problem_mask=match_data.problem_pts(match_data.ind_chosen);
match_data.ind_chosen=match_data.ind_chosen(~problem_mask);


