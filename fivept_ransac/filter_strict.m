function [match_data]=filter_strict(match_data, thres_spatial, image1, image2)




match_data.likelihood_threshold=0.6;
ori=match_data.ind_chosen;

[match_data.ind_chosen]=ind_thres_unique(match_data.matches_all, match_data.ind_chosen);
if length(match_data.ind_chosen)<10
    match_data.ind_final=[];
    return;
end;
[match_data, lambda]=likelihood_filter_force(match_data, 0.6, 1);
[match_data.ind_chosen]=ind_thres_unique(match_data.matches_all, match_data.ind_chosen);
if length(match_data.ind_chosen)<10
    match_data.ind_chosen=[];
    match_data.ind_final=[];
    return;
end;
[match_data]=affine_verification_strict(match_data, thres_spatial);

%return;

if length(match_data.ind_chosen)<1200
    
    %num_needed=5000-length(match_data.ind_chosen);
    num_needed=floor(0.2*length(match_data.ind_chosen));
    num_needed=min(length(ori), num_needed);
    ind=randsample(length(ori), num_needed);
    match_data.ind_chosen=cat(1, match_data.ind_chosen, ori(ind));
end;

[match_data.ind_chosen]=ind_thres_unique(match_data.matches_all, match_data.ind_chosen);
[match_data, lambda]=likelihood_filter_strict(match_data, 0.6,1);
[match_data.ind_chosen]=ind_thres_unique(match_data.matches_all, match_data.ind_chosen);
if length(match_data.ind_chosen)<10
    match_data.ind_chosen=[];
    match_data.ind_final=[];
    return;
end;
[match_data]=affine_verification_strict(match_data, thres_spatial);


if nargin==4
    display_match_struc(uint8(image1), uint8(image2),match_data);
end;

