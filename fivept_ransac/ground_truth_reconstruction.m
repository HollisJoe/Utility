
K1=[2759.48 0 1520.69; 0 2764.16 1006.81; 0  0 1];

[pose]=N_view_ground_truth([0:9], 'C:\Data\entry\', 3);
export_to_cmpmvs(pose, path_all, K1, 'C:/Data/gt/entry/');