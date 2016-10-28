function [matchings]=get_pure_bf(path_all, ind1, ind2)

path_a=path_all(ind1).path;
path_b=path_all(ind2).path;


fileID = fopen(strcat(path_all(1).folder,'\matchings.txt'),'r');

found=0;
matchings=[];

while (~feof(fileID))
    cur = fgetl(fileID);
    if strcmp(path_a,cur)
        cur = fgetl(fileID);
        if strcmp(path_b,cur)
            found=1;
            break;
            
            
            
        end;
    end;
end;

if found==1
    fgetl(fileID);
    cur = fgetl(fileID);
    
    x = str2num(cur);
    cur = fgetl(fileID);
    y= str2num(cur);
    matchings=cat(1,x,y)+1;    
    
end;
fclose(fileID);

