function [num, aff, all_match, xy1, xy2, seletced_index]=read_pair(path_all, im1, im2)
% im1 and im2 are numbers, im2 must be greater than im1

[num, xy1]=read_vsfm_sift([path_all(im1).folder,'/',path_all(im1).im_name, '.sift']);
[~, xy2]=read_vsfm_sift([path_all(im2).folder,'/',path_all(im2).im_name, '.sift']);
[aff]=read_affine_sift([path_all(im1).folder,'/affine_all',path_all(im1).im_name,path_all(im1).type...
    '_',path_all(im2).im_name,path_all(im2).type, '.txt']);
[all_match]=read_affine_sift([path_all(im1).folder,'/all_match',path_all(im1).im_name,path_all(im1).type...
    '_',path_all(im2).im_name,path_all(im2).type, '.txt']);
all_match=all_match+1; % convert to matlab index
[seletced_index]=read_affine_sift([path_all(im1).folder,'/selected_match',path_all(im1).im_name,path_all(im1).type...
    '_',path_all(im2).im_name,path_all(im2).type, '.txt']);
seletced_index=(seletced_index+1)'; % convert to matlab index
