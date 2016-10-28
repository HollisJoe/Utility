function [R, T]=bundle_adj_essential(pose, p1, p2)

global P1;
global P2;

P1=p1;
P2=p2;


x0 =pose2x(pose);


options = optimset('Jacobian','on', 'display', 'off');


[x,resnorm] = lsqnonlin(@essential_error,x0,[],[],options); 


pose=x2pose(x);
R=pose(:,1:3);
T=pose(:,4);
T=T/norm(T);
