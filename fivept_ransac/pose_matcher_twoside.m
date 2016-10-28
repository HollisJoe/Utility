%function []=pose_matcher_twoside(path_all,  ind1,   ind2)
K1=[3860.67 0 2592; 0 3860.67 1728; 0  0 1]; %hdb
K2=[3860.67 0 2592; 0 3860.67 1728; 0  0 1];

[index_final1,all_matches1, x1, x2, m_e1, pose1]=pose_matcher_new_form(path_all,  ind1,   ind2);

[index_final2,all_matches2, ~, ~, m_e2, pose2]=pose_matcher_new_form(path_all,  ind2,   ind1);

pose1
pose2

pass1=zeros(1, length(all_matches1));
pass1(index_final1)=1;


pass2=zeros(1, length(all_matches2));
pass2(index_final2)=1;





pass1_pass2=pass2(all_matches1(2,index_final1));
pass1_pass2=pass1_pass2==1;
index_final=index_final1(pass1_pass2);
final_match=[1:size(x1,2);1:size(x1,2)];

% 
% 
% pass_both=zeros(1, length(all_matches1));
% pass_both(index_final1)=pass2(all_matches1(2,index_final1));
% index_final=find(pass_both);

image1=imread(path_all(ind1).path);
image2=imread(path_all(ind2).path);

[ok, m_e]=remove_points2(pose1, x1, x2, final_match, K1, K2, image1, image2,1);


[ok, m_e]=remove_points2(pose1, x1, x2, final_match(:, pass1_pass2), K1, K2, image1, image2,1);


[ok, m_e]=remove_points2(pose2, x1, x2, final_match(:, pass1_pass2), K1, K2, image1, image2,1);

