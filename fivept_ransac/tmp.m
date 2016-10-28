r_e=[];
t_e=[];
runner=1;
for i=1:  num_cams-1
    i
    if i~=14
        j=i+1;
        [pose_true,s]=center_pose2(pose(:,:,[i, j]), 1);
        R1=pose_true(:,1:3,2);
        T1=pose_true(:,4,2);
        T1=T1/norm(T1);
        R2=data.pose{i, j}(:,1:3);
        
        T2=data.pose{i, j}(:,4);
        T2=T2/norm(T2);
        
        rot_error=180*rot_mag(R1'*R2)/pi;
        t_error=acosd(T1'*T2);
        
        r_e(runner)=abs(rot_error);
        t_e(runner)=abs(t_error);
        runner=runner+1;
    end;
end;
