function [w,a0]=grad_desc_affine_correct(G, G_all,pp1, pp2, thres)


M=zeros(size(pp1,2), 3*size(G,2)+3);
N=zeros(size(pp1,2),1);

num=size(G,2);
for i=1:size(pp1,2)
    M(i,1:num)=pp1(1,i)*G_all(i,:);
    M(i,num+1:2*num)=pp1(2,i)*G_all(i,:);
    M(i,2*num+1:3*num)=G_all(i,:);
    M(i,3*num+1)=pp1(1,i);
    M(i,3*num+2)=pp1(2,i);
    M(i,3*num+3)=1;
    N(i)=pp2(i);
end;

n=mean(sum(G,1));
lambda=0.1*n;
lambda=2;

lambda_out=lambda;

% if lambda >1
%     lambda=1;
% end;
% if lambda <min_lambda % prevent forcing of matching on images of different places
%     lambda=min_lambda;
% end;

size(M)

size(G)
'cross'

[u,s,v]=svd(G);
G_half=sqrt(s)*v';


%[k] = myfunT2(M,N,thres,G_half,lambda);
 [k,res]=grad_aff_correct(M,N,thres,G_half,lambda);

% k_s=k;
% [k,res]=grad_aff_asym(M,N,thres,G_half,lambda);
% 'checking'
% max(abs(k-k_s))
% mean(abs(k))
% k(end-3:end)
% k_s(end-3:end)
% k=donkey

num=size(G,1);
w=[k(1:num) k(num+1:2*num) k(2*num+1:3*num)];
a0=[k(3*num+1);k(3*num+2);k(3*num+3)];

