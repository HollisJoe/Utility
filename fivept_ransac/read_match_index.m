function [match]=read_match_index(path_)
a=dlmread(path_);
match=a(2:end,:);

 return;