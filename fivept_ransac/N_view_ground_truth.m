function [pose]=N_view_ground_truth(index, main_field, format)

num=length(index);

if format==1
    first_im=index(1);
    
    data_path_a=strcat(main_field,  num2str(first_im), '.txt');
    pose=zeros(3,4, length(index));
    pose(:,:,1)=[eye(3), zeros(3,1)];
    
    for j=2:num
        data_path_b=strcat(main_field, num2str(index(j)), '.txt');
        dat_a=dlmread(data_path_a);
        dat_b=dlmread(data_path_b);
        
        R1=dat_a(4:6,1:3);
        %[o]=dcm2quat(R1);
        %R1=quat2dcm(o);
        R1=R1';
        T1=dat_a(7,1:3)';
        T1=-R1*T1;
        R2=dat_b(4:6,1:3);
        %[o]=dcm2quat(R2);
        %R2=quat2dcm(o);
        R2=R2';
        T2=dat_b(7,1:3)';
        T2=-R2*T2;
        R=R2*R1';
        T=T2-R2*(R1'*T1);
        if j==2
            s=norm(T);
        end;
        
        pose(:,:,j)=[R T/s];
        
        
    end;
    
end;


if format==2
    first_im=index(1);
    
    data_path_a=strcat(main_field,  num2str(first_im), '.txt');
    pose=zeros(3,4, length(index));
    pose(:,:,1)=[eye(3), zeros(3,1)];
    
     for j=2:num
        data_path_b=strcat(main_field, num2str(index(j)), '.txt');
        dat_a=dlmread(data_path_a);
        dat_b=dlmread(data_path_b);
        
        R1=dat_a(4:6,1:3);
%         [o]=dcm2quat(R1);
%         R1=quat2dcm(o);
        T1=dat_a(4:6,4);
        T1=-R1*T1;
        R2=dat_b(4:6,1:3);
%         [o]=dcm2quat(R2);
%         R2=quat2dcm(o);
        T2=dat_b(4:6,4);
        T2=-R2*T2;
        R=R2*R1';
        T=T2-R2*(R1'*T1);
        if j==2
            s=norm(T);
        end;
        
        pose(:,:,j)=[R T/s];
        
        
    end;
    
    
end;



if format==3 %strecha
    first_im=index(1);
    
    data_path_a=strcat(main_field,  num2str(first_im, '%.4d'), '.png.camera');
    pose=zeros(3,4, length(index));
    pose(:,:,1)=[eye(3), zeros(3,1)];
    
     for j=2:num
        data_path_b=strcat(main_field, num2str(index(j), '%.4d'), '.png.camera');
        dat_a=dlmread(data_path_a);
        dat_b=dlmread(data_path_b);
        
        R1=dat_a(5:7,1:3);
        
        
        %[o]=dcm2quat(R1);
        %R1=quat2dcm(o);
        R1=R1';
        T1=dat_a(8,1:3)';
        T1=-R1*T1;
        R2=dat_b(5:7,1:3);
        %[o]=dcm2quat(R2);
        %R2=quat2dcm(o);
        R2=R2';
        T2=dat_b(8,1:3)';
        T2=-R2*T2;
        R=R2*R1';
        T=T2-R2*(R1'*T1);
        if j==2
            s=norm(T);
        end;
        
        pose(:,:,j)=[R T/s];
        
        
    end;
    
    
end;