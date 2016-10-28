function [x]=pose2x(pose)



R=pose(1:3,1:3);
R=R';
T=pose(:,4);
T=-R*T;
x=cat(1,rot_2_angle2(R), T);

