function [sm_a, sm_b, num_a, num_b]=check_accepts_cheap(data, ind1, ind2, ind3, accept_binary)
% accept_binary is a NxN binary matrix indiicating which pairs to consider
% for a pair [i,j], [j,i], only one should be marked 1

sm_a=[];
sm_b=[];
num_a=[];
num_b=[];

pair1=find_pair(accept_binary, ind1, ind2);
pair2=find_pair(accept_binary, ind1, ind3);
if ~isempty(pair1) && ~isempty(pair2)
    [pose_est_a, sm_a, cams_a, num_a]= compute_triplet(data, pair1, pair2);
end;

pair1=find_pair(accept_binary, ind1, ind2);
pair2=find_pair(accept_binary, ind2, ind3);
if ~isempty(pair1) && ~isempty(pair2)    
    [pose_est_b, sm_b, cams_b, num_b]= compute_triplet(data, pair1, pair2);
end;



%[est_a, est_b,est_c]=normalize_tripltes( pose_est_a, pose_est_b(:,:,[sort_b]), pose_est_c(:,:,sort_c));




end


function [pair]=find_pair(accept_binary, ind1, ind2)

if accept_binary(ind1, ind2)==1
    pair=[ind1, ind2];
else
    if accept_binary(ind2,ind1)==1
        pair=[ind2, ind1];
    else
        pair=[];
    end;
end;

end
function [est_a, est_b,est_c]=normalize_tripltes(est_a, est_b, est_c)
ind=0;
max_dist=0;
for ii=1:size(est_a,3)
    s=norm(est_a(:,4,ii));
    if s> max_dist
        max_dist=s;
        ind=ii;
    end;
end;

norm_a=norm(est_a(:,4,ind));
norm_b=norm(est_b(:,4,ind));
norm_c=norm(est_c(:,4,ind));

for jj=1:size(est_a,3)
    est_a(:,4,jj)=est_a(:,4,jj)/norm_a;
    est_b(:,4,jj)=est_b(:,4,jj)/norm_b;
    est_c(:,4,jj)=est_c(:,4,jj)/norm_c;
    
end;
end



function [sorts]=sort_cams(cam_a, cam_s)
sorts=zeros(length(cam_s),1);
for i=1:length(cam_a)
    for j=1:length(cam_s)
        if cam_a(i)==cam_s(j)
            sorts(i)=j;
        end;
    end;
end

end

