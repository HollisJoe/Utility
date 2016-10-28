function [G]=G_compute_fast_single(X, Y, dist_scale)

G = vl_alldist(single(X),single(Y));
%G=G.^2;
G=exp(-dist_scale*G);