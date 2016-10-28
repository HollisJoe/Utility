function [match_data] = match_from_file(path_all, im1, im2)



[num, aff, all_match, xy1, xy2, seletced_index]=read_pair(path_all, im1, im2);
match_data=struct('f1',[], 'f2',[], 'matches_all', [], 'ind_weak', [], 'ind_strong', [],'ind_chosen', [], 'affine_all', [], 'problem_pts',[]);

match_data.f1=xy1(1:2,:);
match_data.f2=xy2(1:2,:);
match_data.affine_all=aff;
match_data.matches_all=all_match;
match_data.ind_weak=seletced_index;
match_data.ind_chosen=seletced_index;
match_data.problem_pts=zeros(1, size(all_match,2));

return;


