function [pose]=iterative_2_view(f1, f2, matches_all, index)

if length(index)>10000 % a lot of matches
    num_iter=1; % no need to iterate
else    
    num_iter=5;
end;

pose_all=zeros(3,4,num_iter);
for i=1:num_iter
    %try
    [pose, F]=pose_simple(f1, f2, matches_all(:,index), eye(3), eye(3),0.001);
    %[pose, F]=pose_economy(f1, f2, matches_all(:,index), eye(3), eye(3),0.001);
    pose_all(:,:,i)=pose;
    %catch
       % pose_all(:,:,i)=[zeros(3,4)];
    %end;
end;

pose_me=median(pose_all,3);

pose_me ;
pose_all ;

error=zeros(num_iter,1);
for i=1:size(pose_all,3)
    error(i)=mean(mean(abs(pose_all(:,:,i)-pose_me)));
end;

[~,ind ]=min(error);

error;
if max(error)> 0.1
    'some estimates are inconsistent'
end


pose=pose_all(:,:,ind);


E=hat(pose(:,4))*pose(:,1:3);
[R_l, T_l, P]=decompose_E(E',cat(2,f1(1:2,matches_all(1,index))',ones(length(index),1)), cat(2,f2(1:2,matches_all(2,index))',ones(length(index),1)));

pose;
pose=[R_l' -R_l'*T_l];
pose;
