function [e]=signed_score(pose, P1, P2)

if size(P1, 1)==2
    P1=cat(1, P1, ones(1, size(P1,2)));
end;


if size(P2, 1)==2
    P2=cat(1, P2, ones(1, size(P2,2)));
end;

if size(pose,2)==4
    R=pose(1:3,1:3);
    T=pose(1:3,4);
    E=hat(T)*R;

else
    E=pose;
end;

lines=(E*P1)';

point_o_line=zeros(2,1);
e=zeros(size(P1,2),1);
% huber_thres=0.0001;%0.001
% huber_thres_2=huber_thres*huber_thres;
for i=1:size(P1,2)
    [val, j]=max(abs(lines(i,1:2)));
    
    
    if j==1
        point_o_line(1)=-lines(i,3)/lines(i,1);
        point_o_line(2)=0;
    else
         point_o_line(1)=0;
        point_o_line(2)=-lines(i,3)/lines(i,2);
    end;
    
    v=point_o_line-P2(1:2,i);
    n=[lines(i,1)
        lines(i,2)];
    n=n/norm(n);
    e(i)=n'*v;
   
        
end;
