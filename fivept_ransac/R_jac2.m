function [ jac_, R ] = R_jac2( o )
o_n=o;
m=norm(o_n);
% if m >1
%     o_n=0.5*o_n/m;
%     o=0.5*o/m;
%     m=0.5;
% end;
R=quat2dcm(cat(1, cos(asin(m)), o_n)');

k=-2*asin(m)/m;
o=k*o;

del_k_x=zeros(3,1);
for i=1:3
    del_k_x(i)=(-k/m-(2/m)*(1/sqrt(1-m^2)))*o_n(i)/m;
end;

del_xo_del_x=zeros(3,3);
for i=1:3
    for j=1:3
        del_xo_del_x(i,j)=del_k_x(j)*o_n(i);
        if i==j
            del_xo_del_x(i,j)= del_xo_del_x(i,j)+k;
        end;
    end;
end;


o_hat=hat(o);
mag=norm(o_hat);
jac=zeros(3,3,3);

a=sin(mag)/mag;
alpha=(cos(mag)/mag^2-sin(mag)/mag^3); %alpha_i=alpha_i*o_i

b=(1-cos(mag))/(mag^2);
beta=sin(mag)/(mag^3)-2*(1-cos(mag))/(mag^4); %beta_i=beta*o_i


jac(1,1,1)=beta*o(1)*(-o(3)^2-o(2)^2);
jac(1,1,2)=beta*o(2)*(-o(3)^2-o(2)^2)-2*b*o(2);
jac(1,1,3)=beta*o(3)*(-o(3)^2-o(2)^2)-2*b*o(3);

jac(1,2,1)=-alpha*o(1)*o(3)+beta*o(1)*o(1)*o(2)+b*o(2);
jac(1,2,2)=-alpha*o(2)*o(3)+beta*o(2)*o(1)*o(2)+b*o(1);
jac(1,2,3)=-alpha*o(3)*o(3)-a+beta*o(3)*o(1)*o(2);

jac(1,3,1)=alpha*o(1)*o(2)+beta*o(1)*o(1)*o(3)+b*o(3);
jac(1,3,2)=alpha*o(2)*o(2)+a+beta*o(2)*o(1)*o(3);
jac(1,3,3)=alpha*o(3)*o(2)+beta*o(3)*o(1)*o(3)+b*o(1);

jac(2,1,1)=alpha*o(1)*o(3)+beta*o(1)*o(1)*o(2)+b*o(2);
jac(2,1,2)=alpha*o(2)*o(3)+beta*o(2)*o(1)*o(2)+b*o(1);
jac(2,1,3)=alpha*o(3)*o(3)+a+beta*o(3)*o(1)*o(1);

jac(2,2,1)=beta*o(1)*(-o(3)^2-o(1)^2)-2*b*o(1);
jac(2,2,2)=beta*o(2)*(-o(3)^2-o(1)^2);
jac(2,2,3)=beta*o(3)*(-o(3)^2-o(1)^2)-2*b*o(3);

jac(2,3,1)=-alpha*o(1)*o(1)-a+beta*o(1)*o(3)*o(2);
jac(2,3,2)=-alpha*o(2)*o(1)+beta*o(2)*o(2)*o(3)+b*o(3);
jac(2,3,3)=-alpha*o(3)*o(1)+beta*o(3)*o(2)*o(3)+b*o(2);

jac(3,1,1)=-alpha*o(1)*o(2)+beta*o(1)*o(1)*o(3)+b*o(3);
jac(3,1,2)=-alpha*o(2)*o(2)-a+beta*o(2)*o(1)*o(3);
jac(3,1,3)=-alpha*o(3)*o(2)+beta*o(3)*o(1)*o(3)+b*o(1);

jac(3,2,1)=alpha*o(1)*o(1)+a+beta*o(1)*o(2)*o(3);
jac(3,2,2)=alpha*o(2)*o(1)+beta*o(2)*o(2)*o(3)+b*o(3);
jac(3,2,3)=alpha*o(3)*o(1)+beta*o(3)*o(2)*o(3)+b*o(2);


jac(3,3,1)=beta*o(1)*(-o(2)^2-o(1)^2)-2*b*o(1);
jac(3,3,2)=beta*o(2)*(-o(2)^2-o(1)^2)-2*b*o(2);
jac(3,3,3)=beta*o(3)*(-o(2)^2-o(1)^2);

jac_=jac;
for i=1:3
    for j=1:3
        for k=1:3
            jac_(i,j,k)= jac(i,j,1)*del_xo_del_x(1, k)+jac(i,j,2)*del_xo_del_x(2, k)+jac(i,j,3)*del_xo_del_x(3, k);
        end;
    end;
end;

%R=eye(3)+sin(mag)/mag*o_hat+(1-cos(mag))/(mag^2)*o_hat*o_hat;

end

