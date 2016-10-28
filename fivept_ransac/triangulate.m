function [P, num_positive]=triangulate(p1,p2, R, T);

P=zeros(size(p1,1),3);
p2_r=(R*p2')';

M=zeros(3,3);
num_positive=0;
%lambda1*p1=lambda2*R*p2+T
for i=1:size(p1,1)
    M(1,1)=p1(i,1);
    M(1,2)=-p2_r(i,1);
    M(1,3)=-T(1);
    M(2,1)=p1(i,2);
    M(2,2)=-p2_r(i,2);
    M(2,3)=-T(2);
    M(3,1)=p1(i,3);
    M(3,2)=-p2_r(i,3);
    M(3,3)=-T(3);
    
    
    [u,s,v]=svd(M); %v(:,3)=[lambda1 lmbda2 1]
    v(:,3)=v(:,3)/v(3,3);
    P(i,:)=v(1,3)*p1(i,:);
    if v(1,3)>0 && v(2,3)>0 
        num_positive=num_positive+1;
    end;
        
    
end;

