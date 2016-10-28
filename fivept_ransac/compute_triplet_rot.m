function [pose_est, s_m, cams, num_common]= compute_triplet_rot(data, pair1, pair2)
s_m=[];

[common, i, j]=find_common(pair1, pair2);


ind1=data.all_matches{pair1(1), pair1(2)}(i, data.index{pair1(1), pair1(2)});
ind2=data.all_matches{pair2(1), pair2(2)}(j, data.index{pair2(1), pair2(2)});

[~,ia,ib] = intersect(ind1,ind2);
num_common=length(ia);

a1=data.coord{pair1(1), pair1(2)};
a1=a1(:, ia);

if i==1
    a2=a1(3:4,:);
    a1=a1(1:2,:);
    pose_a=data.pose{pair1(1), pair1(2)};
    
end;

if i==2
    a2=a1(1:2,:);
    a1=a1(3:4,:);
    pose_a=data.pose{pair1(1), pair1(2)};
    pose_a=cat(2,pose_a(1:3,1:3)', -pose_a(1:3,1:3)'*pose_a(:,4));
    
    
    
end;

b1=data.coord{pair2(1), pair2(2)};
b1=b1(:, ib);
if j==1
    b2=b1(3:4,:);
    b1=b1(1:2,:);
    pose_b=data.pose{pair2(1), pair2(2)};
    
end;

if j==2
    b2=b1(1:2,:);
    b1=b1(3:4,:);
    pose_b=data.pose{pair2(1), pair2(2)};
    pose_b=cat(2,pose_b(1:3,1:3)', -pose_b(1:3,1:3)'*pose_b(:,4));
    
    
end;



scale=1;
if isempty(scale)
    pose_est=[];
    s_m=[];
    cams=[];
    return;
end;
pose_b(:,4)=pose_b(:,4)/scale;
pose_est=cat(3, [eye(3) zeros(3,1)], pose_a, pose_b);
other_a=~(i-1)+1;
other_b=~(j-1)+1;

cams=[common, pair1(other_a), pair2(other_b)];


end

function [common, i, j]=find_common(pair1, pair2)
common=0;

for i=1:length(pair1)
    for j=1:length(pair2)
        if pair1(i)==pair2(j)
            common=pair1(i);
            return;
            
        end;
    end;
end;
end