function [index_final,all_matches, x1, x2, m_e, pose]=asift_save(path_all,  ind1,   ind2, K1, K2)

K1_i=inv(K1);
K2_i=inv(K1);


[match_data] = match_from_file(path_all, ind1, ind2);



index_final=match_data.ind_chosen;

[f1]=calib_data(match_data.f1(1:2,:), K1_i);
[f2]=calib_data(match_data.f2(1:2,:), K2_i);

 pose=iterative_2_view(f1, f2, match_data.matches_all, index_final);



image1=imread(path_all(ind1).path);
image2=imread(path_all(ind2).path);

[ok, m_e]=remove_points2(pose, f1, f2, match_data.matches_all(:, index_final), K1, K2, image1, image2,0);

m_e


index_final=index_final(ok);
x1=f1(1:2, match_data.matches_all(1,index_final));
x2=f2(1:2, match_data.matches_all(2,index_final));

heat_mapped_matches(image1, image2, K1*cat(1, x1,ones(1, size(x1,2))), K2*cat(1, x2,ones(1, size(x2,2))), ['asift_',num2str(ind1), '_', num2str(ind2), 'a.png'], ['asift_',num2str(ind1), '_', num2str(ind2), 'b.png'])
heat_mapped_quiver(image1, K1*cat(1, x1,ones(1, size(x1,2))), K2*cat(1, x2,ones(1, size(x2,2))), ['asift_flow_',num2str(ind1), '_', num2str(ind2), 'a.pdf'])

all_matches=match_data.matches_all;

