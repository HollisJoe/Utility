clear; clc;

res = 'E:/kitti/dataset/res/';
sequence = 'E:/kitti/dataset/res/sequence/01/';
files = dir([sequence '*.txt']);
numFiles = size(files);

output = [res 'poses/01.txt'];
file_t = fopen(output,'a');

for i = 1 : numFiles
    
    try
        Pose = getPose([sequence files(i).name]);
    catch
        'svd crash trying a random soln'
        Pose = getPose([sequence files(i).name]);
    end;
    
    fprintf(file_t,'%f %f %f %f %f %f %f %f %f %f %f %f \n', ...
            Pose(1,1), Pose(1,2), Pose(1,3), Pose(1,4), ...
            Pose(2,1), Pose(2,2), Pose(2,3), Pose(2,4), ...
            Pose(3,1), Pose(3,2), Pose(3,3), Pose(3,4));
end

fclose(file_t);











