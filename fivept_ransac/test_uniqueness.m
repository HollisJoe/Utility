function [wrong_ratio]=test_uniqueness(matches, ind)

wrong_ratio=1-length(unique(matches(2,ind)))/length(matches(2,ind));

 

% m=data.all_matches{ind1,ind2};
% ind=data.index{ind1,ind2};
% m(2,ind)
% unique(m(2,ind))
% wrong_ratio=1-length(unique(m(2,ind)))/length(m(2,ind));