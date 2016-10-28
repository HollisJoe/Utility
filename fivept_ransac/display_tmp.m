
for i=2:4
    display_epipolar_bf_save(path_all, 1, i, K1, K2);
    display_epipolar_bf_save(path_all, i, 1, K1, K2);
    pose_matcher_save(path_all,  1,   i, K1, K2);
    pose_matcher_save(path_all,  i,   1, K1, K2)
     display_asift_save(path_all,  1,   i, K1, K2);



    
end;
