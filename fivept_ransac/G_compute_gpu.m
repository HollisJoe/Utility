function [G]=G_compute_gpu(X, Y)


X1=single(X);
X2=single(Y);


X1_g=gpuArray(X1);
X2_g=gpuArray(X2);


M = bsxfun(@plus, sum(X1_g .* X1_g, 1)', (-2) * X1_g' * X2_g);
M = bsxfun(@plus, sum(X2_g .* X2_g, 1), M);
M=exp(-M);
G=gather(M);




