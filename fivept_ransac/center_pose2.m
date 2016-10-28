function [pose_out,s]=center_pose2(pose, normalize)
if nargin==1
    normalize=0;
end;

R1=pose(1:3,1:3,1);
T1=pose(1:3,4,1);

P_transfer=[R1' -R1'*T1];
P_transfer=cat(1,P_transfer,[0 0 0 1]) ;

pose_out=pose;
for i=1:size(pose,3)
    p_cur=pose(:,:,i);
    
    pose_out(:,:,i)=p_cur*P_transfer;
end;

if normalize
    s=norm(pose_out(1:3,4,2));
    for i=1:size(pose_out,3)
        pose_out(1:3,4,i)=pose_out(1:3,4,i)/s;
    end;
else
    s=1;
end;