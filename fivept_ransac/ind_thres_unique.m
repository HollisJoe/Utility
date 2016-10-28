function [ind_thres]=ind_thres_unique( matches_all, ind_thres)

a=matches_all(1,ind_thres);

[C,IA,IC] = unique(a);

ind_thres=ind_thres(IA);
a=matches_all(2,ind_thres);
[C,IA,IC] = unique(a);
ind_thres=ind_thres(IA);


% V=matches_all(2,ind_thres)';
% [Vs, Vi] = sort(V);                 % sort, Vi are indices into V
% delta = Vs(2:end) - Vs(1:end-1);    % delta==0 means duplicate
% dup1 = Vi(find(delta == 0));        % dup1 has indices of duplicates in V
% dup2 = Vi(find(delta == 0) + 1);    % dup2 has the corresponding other
% % rewrite to [row col]
% 
% if ~isempty(dup1)
%     [dup1(:,1) dup1(:,2)] = ind2sub(size(V), dup1);
%     [dup2(:,1) dup2(:,2)] = ind2sub(size(V), dup2);    
%     dup=cat(1,dup1, dup2);    
%     ind_thres(dup(:,1))=[];
%     
% end;

