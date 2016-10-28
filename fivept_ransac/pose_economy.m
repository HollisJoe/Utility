function [pose, E]=pose_economy(f1, f2, matches_many, K1_i, K2_i, ransac_thres)
if ~exist('ransac_thres', 'var')
    ransac_thres=0.1;
end;

[x1]=calib_data(f1(1:2, matches_many(1,:)), K1_i);
[x2]=calib_data(f2(1:2, matches_many(2,:)), K2_i);

[E, inliers]=ransac_economy(x1', x2', ransac_thres);
[R_l, T_l, P]=decompose_E(E,  x1(:,inliers)', x2(:,inliers)');
%[R_l, T_l, P]=decompose_E_modern(E,  x1(:,inliers)', x2(:,inliers)');



'linear estimate'
E
R_l
T_l
'number of points'
size(x1,2)
'number of inliers'
length(inliers)

% [R, T]=bundle_adj_jac(R_l, T_l, x1(1:3,inliers)',  x2(1:3,inliers)');
% if T'*T_l <0
%     T=-1*T;
% end;
% pose=cat(2, R', -R'*T);



pose=cat(2, R_l', -R_l'*T_l);
[R, T]=bundle_adj_essential(pose, x1(1:3,inliers), x2(1:3,inliers));
if T'*pose(:,4) <0
    T=-1*T;
end;
pose=[R T];

E=hat(pose(:,4))*pose(1:3,1:3);




