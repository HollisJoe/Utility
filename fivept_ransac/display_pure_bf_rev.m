function [matchings, xy1, xy2, im1, im2]=display_pure_bf_rev(path_all, ind1, ind2)

[matchings]=get_pure_bf_rev(path_all, ind1, ind2);
[num, xy1]=read_vsfm_sift([path_all(ind1).folder,'/',path_all(ind1).im_name, '.sift']);
[~, xy2]=read_vsfm_sift([path_all(ind2).folder,'/',path_all(ind2).im_name, '.sift']);

match_final=struct('matches_all', [], 'ind_final', [], 'f1', [], 'f2', []);
match_final.f1=xy1(1:2,:);
match_final.f2=xy2(1:2,:);
match_final.matches_all=matchings;

match_final.ind_final=[1:length(matchings)];



im1=imread(path_all(ind1).path);
im2=imread(path_all(ind2).path);

display_match_struc(uint8(im1), uint8(im2),match_final);
