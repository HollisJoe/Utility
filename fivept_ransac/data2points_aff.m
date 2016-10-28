function [p_all, T1, T2]=data2points_aff(p1, p2, aff, T1, T2)

if nargin==3
    [p1, T1]=normalise2dpts(cat(1, p1,ones(1,size(p1,2))));
    [p2, T2]=normalise2dpts(cat(1, p2,ones(1,size(p2,2))));
else
    p1=T1*cat(1, p1,ones(1,size(p1,2)));
    p2=T2*cat(1, p2,ones(1,size(p1,2)));

end;

%p_all=cat(1, p1(1:2,:),p2(1:2,:)-p1(1:2,:),aff);

p_all=cat(1, p1(1:2,:)/2,p2(1:2,:)-p1(1:2,:),aff, p2(1:2,:)/2);


% p1=p1(1:2,:);
% p2=p2(1:2,:);
% 
% num_pts=size(p1,2);
% 
% v=100*(p2-p1);
% v=cat(1, v, ones(1, num_pts));
% 
% for i=1:num_pts
%     v(:,i)=v(:,i)/norm(v(:,i));
% end;
% 
% p_all=cat(1, p1, p2, 10*v, p1-p2);
