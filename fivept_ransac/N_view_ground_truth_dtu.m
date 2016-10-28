function [pose]=N_view_ground_truth_dtu(index, main_field, format)


K1=[2900.120764843560200 0 791.168475644626030
    0 2890.562160275289900 656.274844704592970
    0 0 1];
K1_i=inv(K1);
num=length(index);

if format==1
    first_im=index(1);
    
    data_path_a=strcat(main_field,   num2str(first_im, '%.3d'), '.txt');
    
    pose=zeros(3,4, length(index));
    pose(:,:,1)=[eye(3), zeros(3,1)];
    
    for j=2:num
        data_path_b=strcat(main_field, num2str(index(j), '%.3d'), '.txt');
        dat_a=dlmread(data_path_a);
        dat_a=K1_i*dat_a;
        dat_b=dlmread(data_path_b);
        dat_b=K1_i*dat_b;
        
        
        R1=dat_a(1:3,1:3);
        [u,~,v]=svd(R1);
        R1=u*eye(3)*v';
        %[o]=dcm2quat(R1);
        %R1=quat2dcm(o);
        R1=R1;
        T1=dat_a(1:3,4);
        %T1=-R1*T1;
        R2=dat_b(1:3,1:3);
        %[o]=dcm2quat(R2);
        %R2=quat2dcm(o);
        R2=R2;
        [u,~,v]=svd(R2);
        R2=u*eye(3)*v';
        T2=dat_b(1:3,4);
        %T2=-R2*T2;
        R=R2*R1';
        T=T2-R2*(R1'*T1);
        if j==2
            s=norm(T);
        end;
       
        pose(:,:,j)=[R T/s];
        
        
    end;
    
end;
