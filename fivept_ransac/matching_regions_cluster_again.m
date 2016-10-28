function [match_store, cluster_index]= matching_regions_cluster_again(match_store, ind_done, d_scale)
%function [match_store, cluster_final]= test_matching_regions_cluster(match_store, ind_done)

if nargin==2
    d_scale=10;
end;


matches_done=match_store.matches_all(:, ind_done);
match_all=match_store.matches_all;
match_test=match_store.matches_all(:, match_store.ind_chosen);


f1_done=match_store.f1(1:2, matches_done(1,:));
f2_done=match_store.f2(1:2, matches_done(2,:));
s1=mean(mean(abs(f1_done)));
s2=mean(mean(abs(f2_done)));

if s1> s2
    d1=d_scale;
    d2=d_scale*s2/s1;
else
    d2=d_scale;
    d1=d_scale*s1/s2;
end;

f1_done=ceil(f1_done/d1);
f2_done=ceil(f2_done/d2);
f1=ceil(match_store.f1(1:2, match_all(1,:))/d1);
f2=ceil(match_store.f2(1:2, match_all(2,:))/d2);

row1=max(f1(2,:));
col1=max(f1(1,:));
start1=min(min(f1(1:2,:)))-1;
map1=zeros(row1-start1, col1-start1);
linearInd1 = sub2ind([row1-start1, col1-start1], f1_done(2,:)-start1, f1_done(1,:)-start1);
map1(linearInd1)=1;


row2=max(f2(2,:));
col2=max(f2(1,:));
start2=min(min(f2(1:2,:)))-1;
map2=zeros(row2-start2, col2-start2);
linearInd2 = sub2ind([row2-start2, col2-start2], f2_done(2,:)-start2, f2_done(1,:)-start2);
map2(linearInd2)=1;

%figure,imshow(map1), title('found matches');
se = strel('disk',2);
map1 = imdilate(map1,se);
se = strel('disk',2);
map2 = imdilate(map2,se);
%figure,imshow(map1), title('unconsidered regions');

f1_test=ceil(match_store.f1(1:2, match_test(1,:))/d1);
% row1+start1
% col1+start1
% max(max(f1_test(1:2,:)+start1))
% min(min(f1_test(1:2,:)+start1))
linearInd1 = sub2ind([row1-start1, col1-start1], f1_test(2,:)-start1, f1_test(1,:)-start1);
ind_test1=map1(linearInd1);


f2_test=ceil(match_store.f2(1:2, match_test(2,:))/d2);
linearInd2 = sub2ind([row2-start2, col2-start2], f2_test(2,:)-start2, f2_test(1,:)-start2);
ind_test2=map2(linearInd2);

ind_test=ind_test1| ind_test2;

map1(:)=0;
map1(linearInd1(ind_test==0))=1;
%figure,imshow(map1), title('match position regions');

match_store.ind_chosen=match_store.ind_chosen(ind_test==0);


p1=match_store.f1(1:2, match_all(1,match_store.ind_chosen));
p2=match_store.f2(1:2, match_all(2,match_store.ind_chosen));
aff=match_store.affine_all;
aff=aff(:, match_store.ind_chosen);

if length(p1)<3
    match_store=[];
    cluster_index=[];
    return;
    
end;
    
    

[p_all, T1, T2]=data2points_aff(p1, p2, aff);

num_sample=max(1,floor(length( match_store.ind_chosen)/40));

if num_sample> 20
    num_sample=20;
end;

length(p_all)

runner=1;
cluster_index=struct('chosen',[], 'cluster_center', []);


if length(p_all)<10
    match_store=[];
    cluster_index=[];
    return;
    
end;

for j=1:1
    num_sample
    [Idx,C]= kmeans(p_all',num_sample, 'emptyaction','singleton');
    
    for i=1:num_sample
        cluster_index(runner).chosen=find(Idx==i);
        cluster_index(runner).cluster_ceneter=C(i,:);
        runner=runner+1;
    end;
end;



