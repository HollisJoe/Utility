function [num_sifts, xy]=read_vsfm_sift(path_)
fileID = fopen(path_);
a=fread(fileID);

runner=1;
space=4;
for i=1:5
    cur=typecast(uint8([a(runner:runner+space-1)]),'int32');
    runner=runner+space;
    if i==3
        num_sifts=cur;
    end;
end;


 xy=typecast(uint8([a(runner:runner+space*num_sifts*5-1)]),'single');
 xy=double(reshape(xy, [5, num_sifts]));
 fclose(fileID);
% [x;y;0;scale;angle]
 return;
 
 
