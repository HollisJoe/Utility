addpath('toolbox_graph\toolbox_graph');

K1=[2900.120764843560200 0 791.168475644626030
    0 2890.562160275289900 656.274844704592970
    0 0 1];
row=1200;
col=1600;

%[vertex] = read_ply2('C:\Users\daniel.lin\Downloads\SampleSet\SampleSet\MVS Data\Points\furu\furu001_l3.ply');
[pose]=N_view_ground_truth_dtu([1:49], 'C:\Users\daniel.lin\Downloads\SampleSet\SampleSet\MVS Data\Calibration\cal18\pos_', 1);
num_cams=size(data.m_e,1);

overlap=cell(num_cams,1);
for i=1:num_cams
    overlap{i}=[1:num_cams];
end;

% 
% data_bf=load('entry_bf.mat','data');
% data_bf=data_bf.data;





evaluation_data=struct('rot_error', [], 'trans_error', [], 'pairs', [], 'rot_mag', [], 'trans_mag', []);
tested=zeros(num_cams, num_cams);
runner=1;
for i=1:  num_cams
    for j=1:length(overlap{i})
        im_test=overlap{i}(j);
        if i~=im_test && tested(i,im_test)==0 && tested(im_test,i)==0
            tested(i, im_test)=1;
            tested(im_test, i)=1;

            pairs=sort([i, im_test]);
            [pose_true,s]=center_pose2(pose(:,:,[pairs(1), pairs(2)]), 1);
            R1=pose_true(:,1:3,2);
            T1=pose_true(:,4,2);
            T1=T1/norm(T1);
            
            R1
            
            evaluation_data(runner).pairs=pairs;
            evaluation_data(runner).rot_mag=180*rot_mag2(R1)/pi;
            evaluation_data(runner).trans_mag=s;
            
            
            if ~isempty(data.pose{pairs(1), pairs(2)})
                
                im_test
                cat(2, pose_true(:,:,2), data.pose{pairs(1), pairs(2)})
               
                R2=data.pose{pairs(1), pairs(2)}(:,1:3);
                T2=data.pose{pairs(1), pairs(2)}(:,4);
                T2=T2/norm(T2);
                
                rot_error=180*rot_mag2(R1'*R2)/pi;
                t_error=acosd(T1'*T2);
                rot_error
                t_error
                evaluation_data(runner).rot_error=rot_error;
                evaluation_data(runner).trans_error=t_error;
               
                runner=runner+1;
                
            else
                evaluation_data(runner).rot_error=1000;
                evaluation_data(runner).trans_error=1000;
                runner=runner+1;
            end
            
        end;
        
    end;
end;





plot_evaluation(evaluation_data, evaluation_data);



%%%%%%%%%%%%%%%%%%%%%%%%
% matching evalutaion


for i=1:length(evaluation_data)
    im1=evaluation_data(i).pairs(1);
    im2=evaluation_data(i).pairs(2);
    if ~isempty(data.coord{im1,im2})
        num=size(data.coord{im1,im2}(1:2,:),2);
        [ok, m_e]=remove_points2(data.pose{im1, im2}, data.coord{im1,im2}(1:2,:), data.coord{im1,im2}(3:4,:), [1:num;1:num], eye(3), eye(3), [], [],0);
        
        evaluation_data(i).percent=matching_error(vertex', pose(:,:,im1), pose(:,:,im2), K1, row, col, data.coord{im1,im2}(:,ok), 0.04);
    else
        evaluation_data(i).percent=0;
    end;
    
    
end;




matching_evaluation(evaluation_data, evaluation_data);




%%%%%%%%%%%%%%%%%%%%%%%%
% pairwise evalutaion

r_e=[];
t_e=[];
runner=1;
for i=1:  num_cams-1
    
    %if i~=14
        j=i+1;
        [pose_true,s]=center_pose2(pose(:,:,[i, j]), 1);
        R1=pose_true(:,1:3,2);
        T1=pose_true(:,4,2);
        T1=T1/norm(T1);
        R2=data.pose{i, j}(:,1:3);
        
        T2=data.pose{i, j}(:,4);
        T2=T2/norm(T2);
        
        rot_error=180*rot_mag(R1'*R2)/pi;
        t_error=acosd(T1'*T2);
        
        r_e(runner)=abs(rot_error);
        t_e(runner)=abs(t_error);
        runner=runner+1;
    %end;
end;

'asift av rotation error'
mean(r_e)

'asift av translation error'
mean(t_e)
   


