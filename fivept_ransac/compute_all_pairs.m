%function []=compute_all_pairs(path_all)
% 
% K1=[4087.75 0 2592;    0 4087.75 1728; 0  0 1];
% K2=[4087.75 0 2592;    0 4087.75 1728; 0  0 1]; %borad, adsc

% K1=[5450 0 2592; 0 5450 1728; 0  0 1];
% K2=[5450 0 2592; 0 5450 1728; 0  0 1]; %i2r

% K1=[2951 0 2592; 0 2951 1728; 0  0 1];
% K2=[2951 0 2592; 0 2951 1728; 0  0 1]; %simple cam

% 
% K1=[ 3011.78849 0  1803.39070; 0 3013.99309 1250.73020; 0  0 1];
% K2=[ 3011.78849 0  1803.39070; 0 3013.99309 1250.73020; 0  0 1]; %simple cam
% 

% K1=[ 6624.070862 0  1008.853968; 0 6624.070862 1132.158299; 0  0 1];
% K2=[ 6624.070862 0  1008.853968; 0 6624.070862 1132.158299; 0  0 1]; %dino

% K1=[ 2759.48 0  1520.69; 0 2764.16 1006.81; 0  0 1];
% K2=[ 2759.48 0  1520.69; 0 2764.16 1006.81; 0  0 1]; %strecha
% 


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
    
    if ~(data.check_matrix(i,j)==1)
        close all
        
        try
            [index_final,all_matches, x1, x2, m_e, pose]=pose_matcher_new_form(path_all, i,j, K1, K2);
            data.m_e(i,j)=m_e;
            data.coord{i,j}=cat(1, x1,x2);
            data.all_matches{i,j}=all_matches;
            data.index{i,j}=index_final;
            data.pose{i,j}=pose;



            
            
%             if length(index_final)>10 && m_e<9e-4
%                 
%                 file_newmatch = fopen(new_match_file,'at');
%                 fprintf(file_newmatch, '%s\n', cur1);
%                 fprintf(file_newmatch, '%s\n', cur2);
%                 fclose(file_newmatch);
%                 
%                 dlmwrite(new_match_file, length(index_final), '-append');
%                 dlmwrite(new_match_file, all_matches(1,index_final)-1, '-append', 'delimiter',' ');
%                 dlmwrite(new_match_file, all_matches(2,index_final)-1, '-append', 'delimiter',' ');        
%                 
%                 file_newmatch = fopen(new_match_file,'at');
%                 fprintf(file_newmatch, '\n');
%                 fclose(file_newmatch);
%                 
%             end;
        catch
        end;
        data.check_matrix(i,j)=1;
        data.check_matrix(j,i)=1;
        %return;
        
    end;
    fgetl(fileID);    % ignore useless lines
    fgetl(fileID);
    fgetl(fileID);
    fgetl(fileID);
    
    
    
end;

fclose(fileID);

%return;

[accepted]=accepted_pairs(data); %spaning tree
for i=1:num_images
    for j=i+1:num_images
        if accepted(i,j)<0
            try
                [index_final,all_matches, x1, x2, m_e, pose]=pose_matcher_new_form(path_all, j,i, K2, K1);
                [wrong_ratio]=test_uniqueness(all_matches, index_final);
                data.m_e(j,i)=m_e;
                data.coord{j,i}=cat(1, x1,x2);
                data.all_matches{j,i}=all_matches;
                data.index{j,i}=index_final;
                data.pose{j,i}=pose;
                if wrong_ratio < abs(accepted(i,j))% && wrong_ratio<0.2
                    accepted(j,i)=wrong_ratio;
                end;
            catch
                
            end;
            
        end;
    end;
end;


% [accepet_binary, final_score]=final_decision(data, abs(accepted)); %triplet verification
[accepet_binary, final_score]=final_decision(data); %triplet verification

write2vsfm(path_all, data, final_score); 
write2vsfm_all(path_all, data);

%write2vsfm_seq(path_all, data, final_score); 



