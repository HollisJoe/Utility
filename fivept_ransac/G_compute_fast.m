function [G]=G_compute_fast(X, Y, dist_scale)

% G = vl_alldist(single(X),single(Y));
% %G=G.^2;
% G=double(G);
% G=exp(-dist_scale*G);


G = vl_alldist(X,Y);
G=exp(-dist_scale*G);



