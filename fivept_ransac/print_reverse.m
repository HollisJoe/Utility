function []=print_reverse(path_all)
main_folder=path_all(1).folder;
image_list=[main_folder, '/', 'image_reverse_list.txt'];
fileID = fopen(image_list,'w');
for i=length(path_all):-1:1
    %path_all(i).path
    fprintf(fileID,[path_all(i).path,'\n']);    
end;
fclose(fileID);
% 
cmd=['Daniel_demo_reverse',  ' ', image_list];
system(cmd);