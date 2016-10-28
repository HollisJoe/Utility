function [pose, pose_jac]=x2pose(x)


pose_jac=zeros(3,4,6);
[R_j,R]=R_jac2(x(1:3));
R_=R';
for i=1:3
    pose_jac(1:3,1:3,i)=R_j(1:3,1:3,i)';
end;

T=[x(4)
    x(5)
    x(6)];

for i=1:3
    pose_jac(1:3,4,i)=-pose_jac(1:3,1:3,i)*T;
end;
for i=4:6
    pose_jac(1:3,4,i)=-R_(:,i-3);
end;
pose=cat(2, R', -R'*T);
