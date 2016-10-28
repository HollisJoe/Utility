function [affs]=read_affine_sift(path_)
a=dlmread(path_);
affs=a(2:end,:);
 return;
 
 