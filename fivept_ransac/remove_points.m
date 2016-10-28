function [inliers]=remove_points(pose, f1, f2, matches_all,  K1_ori, K2_ori, im_ori1, im_ori2, thres, display)



[e]=signed_score(pose, f1(1:2, matches_all(1,:)), f2(1:2, matches_all(2, :)));

inliers=find(abs(e)< thres);
%inliers=find(abs(e)< 1.48*m_e);

[x1]=calib_data(f1(1:2,:), K1_ori);
[x2]=calib_data(f2(1:2,:), K2_ori);

if display
    
    length(matches_all)
    length(inliers)
    display_match_trad_enum(uint8(im_ori1), uint8(im_ori2), matches_all(:, inliers), x1(1:2,:),x2(1:2,:));
end;
