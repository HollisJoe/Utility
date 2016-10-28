% first_im=84;
% step=1;
% last_im=96;
first_im=1;
step=1;
last_im=50;
main_field='C:\Data\daniel_data\daniel_data\Aerial\DSC';
match_field='C:\Data\daniel_data\daniel_data\Aerial\match';

type='.jpg';

res=960;
% calibration=struct('fc', [], 'cc',[], 'alpah_c', [], 'kc', []); % digi 
% calibration.fc=[ 1529.726  1529.726  ]; 
% calibration.cc=[  960  540]; 
% calibration.alpha_c=[ 0 ];
% calibration.kc=[ 0 0 0 0 0 ];


calibration=struct('fc', [], 'cc',[], 'alpah_c', [], 'kc', []); % lense 10mm 
calibration.fc=[ 870.79 870.79]; 
calibration.cc=[ 640  425.5 ]; 
calibration.alpha_c=[ 0 ];
%calibration.kc=[ -0.00419   -0.01011   -0.00122   0.00142  0.00000 ];
calibration.kc=[ 0 0 0 0 0 ];
% 2420  2592 2420 1728

calibration2=struct('fc', [], 'cc',[], 'alpah_c', [], 'kc', []); % lense 10mm 
calibration2.fc=[ 1168.8 1168.8 ]; 
calibration2.cc=[ 800  450 ]; 
calibration2.alpha_c=[ 0 ];
%calibration.kc=[ -0.00419   -0.01011   -0.00122   0.00142  0.00000 ];
calibration2.kc=[ 0 0 0 0 0 ];

path_all=struct('path', [], 'path_d', [], 'path_f', [], 'K', []);
num_images=0;
for i=183:step:194
    num_images=num_images+1;
    path_all(num_images).path=strcat(main_field, {''}, num2str(i, '%.5d'), type);
    path_all(num_images).path_d=strcat(main_field,'_', num2str(res),  '_des',num2str(i, '%.1d'), '.bin');
    path_all(num_images).path_f=strcat(main_field,'_', num2str(res), '_f',num2str(i, '%.1d'), '.bin');
    path_all(num_images).K=calibration;        
    
end;

main_field='C:\Data\daniel_data\daniel_data\StreetView\';
for i=1:step:18
    num_images=num_images+1;
    path_all(num_images).path=strcat(main_field, {''}, num2str(i, '%.4d'), type);
    path_all(num_images).path_d=strcat(main_field,'_', num2str(res),  '_des',num2str(i, '%.1d'), '.bin');
    path_all(num_images).path_f=strcat(main_field,'_', num2str(res), '_f',num2str(i, '%.1d'), '.bin');
    path_all(num_images).K=calibration2;        
    
end;

images=struct('num', [],'images_index', [], 'pose', [], 'Z', [], 'se', [], 'problem', [], 'x1',[], 'x2',[]); %images with matches.
num_images=length(path_all);
%num_images=10;
for i=1:num_images
    images(i).num=0;
    images(i).images_index=cell(num_images,1);
    images(i).pose=cell(num_images,1);
    images(i).Z=cell(num_images,1);
    images(i).se=cell(num_images,1);
    images(i).x1=cell(num_images,1);
    images(i).x2=cell(num_images,1);
    images(i).problem=cell(num_images,1);
end

return;
[V]=tilts_sample2(7);
for i=1:num_images
    im=imread(path_all(i).path{1});
    [image1, s1]=im_shrink2(im, im,res);
    
    sift_des(image1, V, path_all(i).path_f, path_all(i).path_d);
end;

% 
% bi=[13
%     20];
% match_new_form(bi,images,path_all,match_field);
% match_set_file(bi,images,path_all,match_field);

step=1;
for i=1:step:length(images)-1
    for j=i+step:step:length(images)
        bi=[i
            j];
        try
            [images]=match_new_form(bi,images,path_all,match_field);
        catch
        end;
    end;
end;



[groups, Seed]=mix_seq_c(images, [1:length(images)]);
[groups_link,images2]=iterative_merging_robusted(Seed,1,2, images);
[groups_link,images2]=force_merged3(Seed,1, 2, images);
[recon1, points]=reconstruction_retry(groups_link, images2);
exportMeshlab(recon1.recon, 'test1.ply' );
export_to_cmpmvs3(groups_link,recon1, points1, path_all);

return;
[group_2,recon, points, rejects]=force_merge_ideal2(Seed2,1, 2, images);
[recon1, points]=reconstruction_retry(groups_link, images2);
exportMeshlab(recon1.recon, 'test1.ply' );
[pose_ba1, pts]=simulation_bundle(images, groups_t);
export_to_cmpmvs2(group_2,recon, points, path_all,calibration);
