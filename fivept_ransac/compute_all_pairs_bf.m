%function []=compute_all_pairs(path_all)
% K1=[3860.67 0 2592; 0 3860.67 1728; 0  0 1]; %hdb
% K2=[3860.67 0 2592; 0 3860.67 1728; 0  0 1];

%  K1=[2018 0 960;    0 2018 640; 0  0 1];
%  K2=[2018 0 960;   0 2018 640; 0  0 1]; %uiuc
% 
% K1=[ 3011.78849 0  1803.39070; 0 3013.99309 1250.73020; 0  0 1];
% K2=[ 3011.78849 0  1803.39070; 0 3013.99309 1250.73020; 0  0 1]; %simple cam
% 
% 
% K1=[ 3011.78849 0  1803.39070; 0 3013.99309 1250.73020; 0  0 1];
% K2=[ 3011.78849 0  1803.39070; 0 3013.99309 1250.73020; 0  0 1]; %simple cam


K1=[ 2759.48 0 1520.69; 0 2764.16 1006.81; 0  0 1];
K2=[ 2759.48 0 1520.69; 0 2764.16 1006.81; 0  0 1]; % strecha




num_images=length(path_all);
data=struct('check_matrix', [], 'm_e', [], 'all_matches', [], 'coord', [], 'index', [], 'pose',[]);
data.check_matrix=NaN(length(path_all), length(path_all));
data.m_e=NaN(length(path_all), length(path_all));
data.all_matches=cell(length(path_all),length(path_all));
data.coord=cell(length(path_all),length(path_all));
data.index=cell(length(path_all),length(path_all));
data.pose=cell(length(path_all),length(path_all));




fileID = fopen(strcat(path_all(1).folder,'\matchings.txt'),'r');


while (~feof(fileID))
    cur1= fgetl(fileID);
    cur1
    C1 = strsplit(cur1, {'\','/','.'});
    for  i=1: length(path_all)
        if strcmp(path_all(i).im_name, C1(end-1))
            break;
        end;
        
    end;
    
    cur2= fgetl(fileID);
    C2 = strsplit(cur2, {'\','/','.'});
    for  j=1: length(path_all)
        if strcmp(path_all(j).im_name, C2(end-1))
            break;
        end;
        
    end;
    close all;
    
    [matchings, xy1, xy2, image1, image2]=display_pure_bf(path_all, i, j);
    x1=cat(1, xy1(1:2,:), ones(1, length(xy1)));
    x2=cat(1, xy2(1:2,:), ones(1, length(xy2)));
    x1=inv(K1)*x1;
    x2=inv(K2)*x2;
    pose=iterative_2_view(x1, x2, matchings, [1:length(matchings)]);
%     [ok, m_e]=remove_points2(pose, x1, x2, matchings, K1, K2, image1, image2,1);
%     matchings=matchings(:,ok);
%     
    
    data.m_e(i,j)=m_e;
    data.coord{i,j}=cat(1, x1(1:2,matchings(1,:)),x2(1:2,matchings(2,:)));
    data.all_matches{i,j}=matchings;
    data.index{i,j}=[1:length(matchings)];
    data.pose{i,j}=pose;
    
    
    
    
    fgetl(fileID);    % ignore useless lines
    fgetl(fileID);
    fgetl(fileID);
    fgetl(fileID);
    
    
    
end;

fclose(fileID);

return;

[accepted]=accepted_pairs(data); %spaning tree

for i=1:num_images
    for j=i+1:num_images
        if accepted(i,j)<0
            close all;
            
            try
                
                [matchings, xy1, xy2, image1, image2]=display_pure_bf_rev(path_all, j,i);
                x1=cat(1, xy1(1:2,:), ones(1, length(xy1)));
                x2=cat(1, xy2(1:2,:), ones(1, length(xy2)));
                x1=inv(K1)*x1;
                x2=inv(K2)*x2;
                pose=iterative_2_view(x1, x2, matchings, [1:length(matchings)]);
                [ok, m_e]=remove_points2(pose, x1, x2, matchings, K1, K2, image1, image2,1);
                %matchings=matchings(:,ok);
                [wrong_ratio]=test_uniqueness(matchings, [1:length(matchings)]);
                
                if wrong_ratio < abs(accepted(i,j))% && wrong_ratio<0.2
                    accepted(j,i)=wrong_ratio;
                end;
                
                data.m_e(j,i)=m_e;
                data.coord{j,i}=cat(1, x1(1:2,matchings(1,:)),x2(1:2,matchings(2,:)));
                data.all_matches{j,i}=matchings;
                data.index{j,i}=[1:length(matchings)];
                data.pose{j,i}=pose;
            catch
                
            end;
        end;
    end;
end;

[accepet_binary, final_score]=final_decision(data); %triplet verification
write2vsfm_bf(path_all, data, final_score);



