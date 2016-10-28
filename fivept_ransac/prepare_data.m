% addpath('C:\Users\daniel.lin\Documents\MATLAB\vlfeat-0.9.14\toolbox');
% vl_setup;
% 
% first_im=0;
% step=1;
% last_im=1;
% main_folder='C:/Data/asift/random';
% common_prefix='';
% type='.png';


addpath('C:\Users\daniel.lin\Documents\MATLAB\vlfeat-0.9.14\toolbox');
vl_setup;

first_im=1;
step=1;
last_im=49;
main_folder='C:/Data/asift/dtu_2';
common_prefix='IMG_';
type='.png';



path_all=struct('path', [], 'folder',[], 'im_name', [], 'type', []);
num_images=0;
for i=first_im:step:last_im
    num_images=num_images+1;
    im_name=[common_prefix, num2str(i, '%.1d')];
    path_all(num_images).path=strcat(main_folder, '/', im_name, type);
    path_all(num_images).folder=main_folder;
    path_all(num_images).im_name=im_name;
    path_all(num_images).type=type;
    
    
end;

image_list=[main_folder, '/', 'image_list.txt'];
fileID = fopen(image_list,'w');
for i=1:length(path_all)
    fprintf(fileID,[path_all(i).path,'\n']);    
end;
fclose(fileID);

cmd=['Daniel_demo_1',  ' ', image_list];
system(cmd);

%print_reverse(path_all)

%[num, aff, all_match, xy1, xy2, seletced_index]=read_pair(path_all, 1, 2);

%[Z, se, problem, pose_final,x1, x2, x1_core, x2_core]=pose_matcher_new_form(path_all,  1,   2);

compute_all_pairs_asift
return;


