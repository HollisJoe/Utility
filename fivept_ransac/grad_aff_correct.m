function [x,res]=grad_aff_correct(M_a, N_a, thres_a,  G_a,  lambda_a)

global M;
global N;
global thres;
global G;
global lambda;
global num;
num=size(G_a,2);

M=M_a;
N=N_a;
thres=thres_a;
G=G_a;
lambda=lambda_a;

% if lambda <min_lambda % prevent forcing of matching on images of different places
%     lambda=min_lambda;
% end;




big_M=cat(1, M, sqrt(lambda)*cat(2,spblkdiag(G,G,G), zeros(3*num,3)));

big_N=cat(1, N, zeros(3*num,1));


xo=big_M\big_N;





%M=zeros(size(M));
% N=zeros(size(N));
%G_cat_rigid=zeros(size(G_cat_rigid));

options = optimset('Jacobian','on', 'display', 'off');
%options = optimset('Jacobian','on', 'display', 'on', 'TolX', 1e-3, 'TolFun', 1e-3);

%options = optimset('Algorithm', 'levenberg-marquardt', 'MaxFunEvals', 10000,'MaxIter', 10000, 'display', 'on');


%xo=zeros(size(M,2),1);
x = lsqnonlin(@myfun,xo, [], [], options);

res=M*x-N;
end

function [e, J]=myfun(x)

global M;
global N;
global thres;
global G;
global lambda;
global num;


e1=M*x-N;
e_sign1=sign(e1);
mask1=abs(e1)> thres;
e1(mask1)=sqrt(2*thres*abs(e1(mask1))-thres^2);

e2=[G*x(1:num);G*x(num+1:2*num);G*x(2*num+1:3*num)];


J1=M;
%num_z=nnz(mask1);
%J1(mask1,:)=0.5*2*thres*diag(1./(e1(mask1).*e_sign1(mask1)))*M(mask1,:);
J1(mask1,:)=thres*diag(1./e1(mask1))*M(mask1,:);
e1(mask1)=e_sign1(mask1).*e1(mask1);

%J1(mask1,:)=0.5*diag(1./(e1(mask1)))*M(mask1,:);

J2=sqrt(lambda)*cat(2,spblkdiag(G,G,G), zeros(3*num,3));
e2=sqrt(lambda)*e2;


e=cat(1, e1, e2);

J=sparse(cat(1, J1, J2));
end


