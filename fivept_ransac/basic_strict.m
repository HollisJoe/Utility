function [match_store]=basic_strict(match_store, thres_spatial, image1, image2)

tic


match_store2=filter_strict_10(match_store,thres_spatial);
ind_all=match_store2.ind_final;
match_store.ind_final=ind_all;
%match_store2.ind_chosen = setdiff(match_store.ind_chosen,ind_all);
% 
% for k=1:5
%     
%     num_needed=min(length(match_store.ind_chosen),0.2*length(ind_all));
%     ind=randsample(length(match_store.ind_chosen), num_needed);
%     ind_test=unique(cat(1, match_store.ind_chosen(ind), ind_all));
%     
%     match_store2.ind_chosen =  ind_test;
%     
%     match_store2=filter_fast(match_store2,thres_spatial);
%     ind_new=unique(cat(1, ind_all, match_store2.ind_final));
%     if length(ind_new)/length(ind_all) >1.05
%         ind_all=ind_new;
%         match_store.ind_final=ind_all;
%     else
%         toc
%         if nargin==4
%             display_match_struc(uint8(image1), uint8(image2),match_store);
%             
%         end;
%         return;
%     end;
% end;


% % match_store3.ind_chosen = setdiff(match_store.ind_chosen,ind_all);
% % 
% % match_store4=filter_nova(match_store3,thres_spatial);
% % ind_all=unique(cat(1, ind_all, match_store4.ind_final));
% 

toc
if nargin==4
    display_match_struc(uint8(image1), uint8(image2),match_store);
    
end;