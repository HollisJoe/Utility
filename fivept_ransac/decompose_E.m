function [R, T, P]=decompose_E(E, p1, p2) %P1=R*P2+T, p1^TEp2=0

if length(p1)>1000
    ind=randsample(length(p1),1000);
    p1=p1(ind,:);
    p2=p2(ind,:);
end;
W=[0 -1 0
    1 0 0
    0 0 1];
[u, s,v]=svd(E);

R1=u*W*v';
R2=u*W'*v';


if det(R1) <0
    R1=-1*R1;
end;

if det(R2)<0
    R2=-1*R2;
end;

T1=u(:,3);
T2=-u(:,3);

lines=p1*E;

l_orth=zeros(3,1);
M=zeros(2,3);

p2_shift=zeros(size(p2,1),3);% place all points on epipolar lines
for i=1:size(p1,1)

    l_orth(1)=-lines(i,2);
    l_orth(2)=lines(i,1);
    l_orth(3)=-(p2(i,1)*l_orth(1) +p2(i,2)*l_orth(2));
    
    M(1,1)=lines(i,1);
    M(1,2)=lines(i,2);
    M(1,3)=lines(i,3);
    M(2,1)=l_orth(1);
    M(2,2)=l_orth(2);
    M(2,3)=l_orth(2);
    
    [u,s,v]=svd(M);
    
    p2_shift(i,:)=v(:,3)/v(3,3);
    
    
end;


[P1, num_positive1]=triangulate(p1,p2, R1, T1);
[P2, num_positive2]=triangulate(p1,p2, R1, T2);
[P3, num_positive3]=triangulate(p1,p2, R2, T1);
[P4, num_positive4]=triangulate(p1,p2, R2, T2);

[val, i]=max(cat(1,num_positive1,num_positive2,num_positive3,num_positive4));


if i==1
    R=R1;
    T=T1;
    P=P1;
    
end;

if i==2
    R=R1;
    T=T2;
    P=P2;
    
end;

if i==3
    R=R2;
    T=T1;
    P=P3;
    
end;

if i==4
    R=R2;
    T=T2;
    P=P4;
    
end;

