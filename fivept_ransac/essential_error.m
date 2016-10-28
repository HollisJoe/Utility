function [e, jac]=essential_error(x)
global P1;
global P2;


[e, jac]=basic_jac_fast(x, P1', P2'); 


% 
% [jac_R,R]=R_jac(x(1:3));
% 
% T=[x(4)
%     x(5)
%     x(6)];
% 
% E=hat(T)*R;
% 
% jac_E=zeros(3,3,6);
% for i=1:3
%     jac_E(:,:,i)=hat(T)*jac_R(:,:,i);
% end;
% tmp=[0 0 0
%     0 0 -1
%     0 1 0];
% jac_E(:,:,4)=tmp*R;
% tmp=[0 0 1
%     0 0 0
%     -1 0 0];
% jac_E(:,:,5)=tmp*R;
% tmp=[0 -1 0
%     1 0 0
%     0 0 0];
% jac_E(:,:,6)=tmp*R; %del_E_x
% 
% 
% lines=P1*E;
% 
% point_o_line=zeros(2,1);
% e=zeros(size(P1,1),1);
% jac_e=zeros(size(P1,1), 9);
% 
% tot=size(P1,1);
% [~, j]=max(abs(lines(:,1:2)));
% mask_a=j==1;
% mask_b=~mask_a;
% point_o_line_x=zeros(tot,1);
% point_o_line_y=zeros(tot,1);
% point_o_line_x(mask_a)=-lines(mask_a,3)./lines(mask_a,1);
% point_o_line_y(mask_b)=-lines(mask_b,3)./lines(mask_b,2);
% 
% point_o_line=cat(2,point_o_line_x,point_o_line_y);
% 
% v=point_o_line-P2(:,1:2);
% 
% N=lines(:,1:2);
% N_mag=sqrt(lines(:,1).^2+lines(:,2).^2);
% N(:,1)=N(:,1)./N_mag;
% N(:,2)=N(:,2)./N_mag;
% 
% e=sum(N.*v,2);
% 
% del_n1_N1=1/sqrt(N(1)^2+N(2)^2)-N(1)^2*(N(1)^2+N(2)^2)^(-1.5);
%     del_n2_N2=1/sqrt(N(1)^2+N(2)^2)-N(2)^2*(N(1)^2+N(2)^2)^(-1.5);
%     del_n1_N2=-N(1)*N(2)*(N(1)^2+N(2)^2)^(-1.5);
%     del_n2_N1=-N(1)*N(2)*(N(1)^2+N(2)^2)^(-1.5);
%     
%     del_e_N1=v(1)*del_n1_N1+v(2)*del_n2_N1;
%     del_e_N2=v(2)*del_n2_N2+v(1)*del_n1_N2;
%     
% 
% 
% for i=1:size(P1,1)
%     [val, j]=max(abs(lines(i,1:2)));
%     
%     
%     if j==1
%         point_o_line(1)=-lines(i,3)/lines(i,1);
%         point_o_line(2)=0;
%     else
%         point_o_line(1)=0;
%         point_o_line(2)=-lines(i,3)/lines(i,2);
%     end;
%     
%     v=point_o_line-P2(i,1:2)';
%     N=[lines(i,1)
%         lines(i,2)];
%     n=N/norm(N);
%     e(i)=n'*v;
%     
%     del_n1_N1=1/sqrt(N(1)^2+N(2)^2)-N(1)^2*(N(1)^2+N(2)^2)^(-1.5);
%     del_n2_N2=1/sqrt(N(1)^2+N(2)^2)-N(2)^2*(N(1)^2+N(2)^2)^(-1.5);
%     del_n1_N2=-N(1)*N(2)*(N(1)^2+N(2)^2)^(-1.5);
%     del_n2_N1=-N(1)*N(2)*(N(1)^2+N(2)^2)^(-1.5);
%     
%     del_e_N1=v(1)*del_n1_N1+v(2)*del_n2_N1;
%     del_e_N2=v(2)*del_n2_N2+v(1)*del_n1_N2;
%     
%     del_e_POL1=n(1);
%     del_e_POL2=n(2);
%     
%     if j==1
%         del_POL1_L1=lines(i,3)/(lines(i,1)^2);
%         del_POL2_L1=0;
%         del_POL1_L2=0;
%         del_POL2_L2=0;
%         del_POL1_L3=-1/lines(i,1);
%         del_POL2_L3=0;
%         
%     else
%         del_POL1_L1=0;
%         del_POL2_L1=0;
%         del_POL1_L2=0;
%         del_POL2_L2=lines(i,3)/(lines(i,2)^2);
%         del_POL1_L3=0;
%         del_POL2_L3=-1/lines(i,2);
%         
%     end;
%     del_e_L1=del_e_POL1*del_POL1_L1+ del_e_POL2*del_POL2_L1+del_e_N1;
%     del_e_L2=del_e_POL1*del_POL1_L2+ del_e_POL2*del_POL2_L2+del_e_N2;
%     del_e_L3=del_e_POL1*del_POL1_L3+ del_e_POL2*del_POL2_L3;
%     
%     jac_e(i,1)=P1(i,1)*del_e_L1;
%     jac_e(i,2)=P1(i,1)*del_e_L2;
%     jac_e(i,3)=P1(i,1)*del_e_L3;
%     jac_e(i,4)=P1(i,2)*del_e_L1;
%     jac_e(i,5)=P1(i,2)*del_e_L2;
%     jac_e(i,6)=P1(i,2)*del_e_L3;
%     jac_e(i,7)=P1(i,3)*del_e_L1;
%     jac_e(i,8)=P1(i,3)*del_e_L2;
%     jac_e(i,9)=P1(i,3)*del_e_L3;  %del_e_E   
% end;
% 
% jac_E(:,:,6)=tmp*R; %del_E_x
% jac=zeros(size(P1,1), 6);
% 
% for i=1:size(P1,1)    
%     for k=1:3
%         jac(i,1)=jac(i,1)+jac_e(i,k)*jac_E(1,k,1);
%         jac(i,2)=jac(i,2)+jac_e(i,k)*jac_E(1,k,2);
%         jac(i,3)=jac(i,3)+jac_e(i,k)*jac_E(1,k,3);
%         jac(i,4)=jac(i,4)+jac_e(i,k)*jac_E(1,k,4);
%         jac(i,5)=jac(i,5)+jac_e(i,k)*jac_E(1,k,5);
%         jac(i,6)=jac(i,6)+jac_e(i,k)*jac_E(1,k,6);              
%     end;
%     for k=1:3
%         jac(i,1)=jac(i,1)+jac_e(i,k+3)*jac_E(2,k,1);
%         jac(i,2)=jac(i,2)+jac_e(i,k+3)*jac_E(2,k,2);
%         jac(i,3)=jac(i,3)+jac_e(i,k+3)*jac_E(2,k,3);
%         jac(i,4)=jac(i,4)+jac_e(i,k+3)*jac_E(2,k,4);
%         jac(i,5)=jac(i,5)+jac_e(i,k+3)*jac_E(2,k,5);
%         jac(i,6)=jac(i,6)+jac_e(i,k+3)*jac_E(2,k,6);
%     end;
%     for k=1:3
%         jac(i,1)=jac(i,1)+jac_e(i,k+6)*jac_E(3,k,1);
%         jac(i,2)=jac(i,2)+jac_e(i,k+6)*jac_E(3,k,2);
%         jac(i,3)=jac(i,3)+jac_e(i,k+6)*jac_E(3,k,3);
%         jac(i,4)=jac(i,4)+jac_e(i,k+6)*jac_E(3,k,4);
%         jac(i,5)=jac(i,5)+jac_e(i,k+6)*jac_E(3,k,5);
%         jac(i,6)=jac(i,6)+jac_e(i,k+6)*jac_E(3,k,6);
%     end;      
% end;
% 
% 
% 
