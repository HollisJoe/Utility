function [match_store, index_main, index_sub]=nova_new_form(match_store, thres_spatial,d_scale, image1, image2)

display=0;
tic
[match_first]=basic_strict(match_store, thres_spatial, image1, image2); %
index_main=match_first.ind_final;

%%%%%%%%%%%%%%%%%%%%%%%
match_store2=match_store;
match_store2.ind_chosen = match_store.ind_chosen;

potential_matches=length(match_store2.ind_chosen);


if length(match_first.ind_final)< 10
    match_store=match_first;
    index_sub=[];
    index_main=[];
    return;
end;


%[match_store2, cluster_index]= test_matching_regions_cluster_sym(match_store2, index_main, d_scale);
[match_store2, cluster_index]= matching_regions_cluster_again(match_store2, index_main, d_scale);
if isempty(cluster_index)
    match_store=match_first;
    index_sub=[];
    return;
end;

ind_new=index_main;

index_sub=struct('index', []);
parfor k=1: length(cluster_index)
%for k=1: length(cluster_index)

    match_store3=match_store2;
    match_store3.ind_chosen=match_store3.ind_chosen(cluster_index(k).chosen);
    
    num_needed=floor(0.2*length(match_store3.ind_chosen));
    if num_needed > length(match_store2.ind_chosen)
        num_needed=length(match_store2.ind_chosen);
    end;
    sam=randsample(length(match_store2.ind_chosen), num_needed);
    
    size(match_store3.ind_chosen)
    size(match_store2.ind_chosen(sam))
    match_store3.ind_chosen=unique(cat(1,match_store3.ind_chosen, match_store2.ind_chosen(sam))); 


    match_store3=filter_strict(match_store3,thres_spatial);
    index_sub(k).index=match_store3.ind_final;
    
%     if display==1
%         display_match_struc(uint8(image1), uint8(image2),match_store3);
%         ind_new=unique(cat(1, ind_new, match_store3.ind_final));
%         match_store.ind_final=ind_new;        
%     end;
    
  
end;
potential_matches
toc
if nargin==6
    display_match_struc(uint8(image1), uint8(image2),match_store);
    
end;

return;

