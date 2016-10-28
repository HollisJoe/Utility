function [e, jac]=basic_jac_fast(x, P1, P2)


[jac_R,R]=R_jac2(x(1:3));

T=[x(4)
    x(5)
    x(6)];

E=hat(T)*R;

jac_E=zeros(3,3,6);
for i=1:3
    jac_E(:,:,i)=hat(T)*jac_R(:,:,i);
end;
tmp=[0 0 0
    0 0 -1
    0 1 0];
jac_E(:,:,4)=tmp*R;
tmp=[0 0 1
    0 0 0
    -1 0 0];
jac_E(:,:,5)=tmp*R;
tmp=[0 -1 0
    1 0 0
    0 0 0];
jac_E(:,:,6)=tmp*R; %del_E_x


lines=P1*E;
jac_e=zeros(size(P1,1), 9);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~, ind]=max(abs(lines(:,1:2)), [],2);

point_o_line=zeros(size(lines,1),2);
mask_a=find(ind==1);
point_o_line(mask_a,1)=-lines(mask_a,3)./lines(mask_a,1);
mask_b=find(ind==2);
point_o_line(mask_b,2)=-lines(mask_b,3)./lines(mask_b,2);
v=point_o_line-P2(:,1:2);
N=sqrt(lines(:,1).^2+lines(:,2).^2);
n=lines(:,1:2);
n(:,1)=n(:,1)./N;
n(:,2)=n(:,2)./N;
e=n(:,1).*v(:,1)+n(:,2).*v(:,2);

N_i=1./N;
N_2=N.*N;
N_i_3=N_2.^(-1.5);

del_n1_N1=N_i-(lines(:,1).^2).*N_i_3;
del_n2_N2=N_i-(lines(:,2).^2).*N_i_3;
del_n1_N2=-lines(:,1).*lines(:,2).*N_i_3;
del_n2_N1=del_n1_N2;

del_e_N1=v(:,1).*del_n1_N1+v(:,2).*del_n2_N1;
del_e_N2=v(:,2).*del_n2_N2+v(:,1).*del_n1_N2;

del_e_POL1=n(:,1);
del_e_POL2=n(:,2);

del_POL1_L1=zeros(size(lines,1),1);
del_POL2_L1=zeros(size(lines,1),1);
del_POL1_L2=zeros(size(lines,1),1);
del_POL2_L2=zeros(size(lines,1),1);
del_POL1_L3=zeros(size(lines,1),1);
del_POL2_L3=zeros(size(lines,1),1);

del_POL1_L1(mask_a)=lines(mask_a,3)./(lines(mask_a,1).^2);
del_POL1_L3(mask_a)=-1./lines(mask_a,1);

del_POL2_L2(mask_b)=lines(mask_b,3)./(lines(mask_b,2).^2);
del_POL2_L3(mask_b)=-1./lines(mask_b,2);
    

del_e_L1=del_e_POL1.*del_POL1_L1+ del_e_POL2.*del_POL2_L1+del_e_N1;
del_e_L2=del_e_POL1.*del_POL1_L2+ del_e_POL2.*del_POL2_L2+del_e_N2;
del_e_L3=del_e_POL1.*del_POL1_L3+ del_e_POL2.*del_POL2_L3;
 



jac_e(:,1)=P1(:,1).*del_e_L1;
jac_e(:,2)=P1(:,1).*del_e_L2;
jac_e(:,3)=P1(:,1).*del_e_L3;
jac_e(:,4)=P1(:,2).*del_e_L1;
jac_e(:,5)=P1(:,2).*del_e_L2;
jac_e(:,6)=P1(:,2).*del_e_L3;
jac_e(:,7)=P1(:,3).*del_e_L1;
jac_e(:,8)=P1(:,3).*del_e_L2;
jac_e(:,9)=P1(:,3).*del_e_L3;


jac=zeros(size(P1,1), 6);

for k=1:3
    jac(:,1)=jac(:,1)+jac_e(:,k).*jac_E(1,k,1);
    jac(:,2)=jac(:,2)+jac_e(:,k).*jac_E(1,k,2);
    jac(:,3)=jac(:,3)+jac_e(:,k).*jac_E(1,k,3);
    jac(:,4)=jac(:,4)+jac_e(:,k).*jac_E(1,k,4);
    jac(:,5)=jac(:,5)+jac_e(:,k).*jac_E(1,k,5);
    jac(:,6)=jac(:,6)+jac_e(:,k).*jac_E(1,k,6);
end;
for k=1:3
    jac(:,1)=jac(:,1)+jac_e(:,k+3).*jac_E(2,k,1);
    jac(:,2)=jac(:,2)+jac_e(:,k+3).*jac_E(2,k,2);
    jac(:,3)=jac(:,3)+jac_e(:,k+3).*jac_E(2,k,3);
    jac(:,4)=jac(:,4)+jac_e(:,k+3).*jac_E(2,k,4);
    jac(:,5)=jac(:,5)+jac_e(:,k+3).*jac_E(2,k,5);
    jac(:,6)=jac(:,6)+jac_e(:,k+3).*jac_E(2,k,6);
end;
for k=1:3
    jac(:,1)=jac(:,1)+jac_e(:,k+6).*jac_E(3,k,1);
    jac(:,2)=jac(:,2)+jac_e(:,k+6).*jac_E(3,k,2);
    jac(:,3)=jac(:,3)+jac_e(:,k+6).*jac_E(3,k,3);
    jac(:,4)=jac(:,4)+jac_e(:,k+6).*jac_E(3,k,4);
    jac(:,5)=jac(:,5)+jac_e(:,k+6).*jac_E(3,k,5);
    jac(:,6)=jac(:,6)+jac_e(:,k+6).*jac_E(3,k,6);
end;



