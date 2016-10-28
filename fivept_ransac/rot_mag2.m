function[mag]=rot_mag2(R)

[u,s,v]=svd(R);
s=eye(3);
R=u*s*v';

[v,d] = eig(R);
%d=real(d);

[row, col]=find(abs(d-1)<0.01);


row=row(1);
dir=v(:,row);
dir=real(dir);
v1=[1 0 0]';
v2=[0 1 0]';


if abs(dir'*v1) < abs(dir'*v2)
    
    test=cross(dir, v1);
    test=test/norm(test);
   
else
   
    
    test=cross(dir, v2);
    test=test/norm(test);
   
end;


 v=R*test;
 
 val1=dir'*cross(v, test);
 val2=v'*test;
 
 mag=sign(val1)*acos(val2);
 