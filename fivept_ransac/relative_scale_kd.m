function [scale, scale_3d, a1, a2, b1, b2]=relative_scale_kd(pose_a, a1, a2, pose_b, b1, b2, thres)

numTrees=3;

if size(b1,2)==0 || size(b2,2)==0
    a1=[];
    a2=[];
    b1=[];
    b2=[];
    scale=[];
    scale_3d=[];
    return;
end;
if exist('thres', 'var') % matches, are preselected
    kdforest = vl_kdtreebuild (b1,  ...
        'verbose', ...
        'numtrees', numTrees) ;
    size(b1)
    size(a1)
    [i, d] = vl_kdtreequery (kdforest, b1, a1, 'numneighbors', 1, 'verbose') ;
    
    matches_all=cat(1, [1:size(a1,2);i]);
    mask=d<thres;
    ind=find(mask);
    matches=matches_all(:, ind);
    
    
    a1=a1(:, matches(1,:));
    a2=a2(:, matches(1,:));
    
    b1=b1(:, matches(2,:));
    b2=b2(:, matches(2,:));
end;


[X_a]=linear_depth(cat(3, [eye(3) zeros(3,1)], pose_a), cat(3, a1(1:2,:), a2(1:2,:)));
[X_b]=linear_depth(cat(3, [eye(3) zeros(3,1)], pose_b), cat(3, b1(1:2,:), b2(1:2,:)));

S=X_b(1:3,:)./X_a(1:3,:);
% 
% figure,
% plot3(X_a, X_b, X_b, 'bd')

scale_3d=median(S');
S_m=mean(median(S'));

mask=abs(S-S_m)<abs(1.48*S_m);
sum(sum(mask))
scale=mean(mean(S(mask)));
% sum(sum(isnan(S)))
% mask
% scale
% k=donk


