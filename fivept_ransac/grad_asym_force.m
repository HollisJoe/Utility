function [x,G_out,G_all_out,lambda_out]=grad_asym_force(p_all, p,N_,thres, min_lambda)

global N;
global t;
global G_all;
global G;
global lambda;
t=thres;

N=N_;


[G]=G_compute_fast(p, p, 1);
%G(G<0.1)=0;



n=mean(sum(G,1));
lambda=0.1*n;

'critical'
n
lambda 
lambda_out=lambda;
lambda=1;

if lambda <min_lambda % prevent forcing of matching on images of different places
    lambda=min_lambda;
end;

%  if lambda >1 && min_lambda~=0 
%      lambda=1;
%  end;

%  if lambda >1 && min_lambda==0 
%      lambda=1;
%  end;


[G_all]=G_compute_fast(p_all, p, 1);
% 
% 'asdas'
% size(G_all)
mask=max(G_all, [], 2)>0.5;
p_all=p_all(:, mask);
N=N(mask);
G_all=G_all(mask,:);

%G_all(G_all<0.1)=0;


[u, s, v]=svd(G);
G=sqrt(s)*v';


big_M=cat(1, G_all, sqrt(lambda)*G);

big_N=cat(1, N, zeros(size(G,1),1));


xo=big_M\big_N;


options = optimset('Jacobian','on', 'display', 'off');

x = lsqnonlin(@myfun,xo, [], [], options);

G_out=G;
G_all_out=G_all;

end

function [e, jac_final]=myfun(x)
global N;
global t;
global G;
global G_all;
global lambda;

e1=(G_all*x-N);
e_sign1=sign(e1);
mask1=abs(e1)> t;
e1(mask1)=sqrt(2*t*abs(e1(mask1))-t^2);

J1=G_all;
num=nnz(mask1);
%val=0.5*2*t*spdiags(1./e1(mask1).*e_sign1(mask1), 0, num, num);
 val=t*spdiags(1./e1(mask1), 0, num, num);
 e1(mask1)=e_sign1(mask1).*e1(mask1);

J1(mask1,:)=val*G_all(mask1,:);

e2=G*x;

e2=sqrt(lambda)*e2;
J2=sqrt(lambda)*G;
% 
e=cat(1,e1, e2);
jac_final=cat(1, J1, J2);

end


