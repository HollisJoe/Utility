function [pose_convert, P, r_error, t_error] = getPose( file )
%GETPOSE Summary of this function goes here
%   Detailed explanation goes here
file_t = fopen(file,'r');
num = fscanf(file_t,'%f',1);
x1 = fscanf(file_t,'%f',num * 2);
x2 = fscanf(file_t,'%f',num * 2);
C = fscanf(file_t,'%f',9);
P = fscanf(file_t,'%f',12);
fclose(file_t);

x1 = reshape(x1,[2 num]);  x1(3, :) = 1.0;
x2 = reshape(x2,[2 num]);  x2(3, :) = 1.0;
C = reshape(C, [3 3]);
P = reshape(P, [3 4]);

% x1(2,:)=376-x1(2,:);
% x2(2,:)=376-x2(2,:);
% x1(1,:)=1241-x1(1,:);
% x2(1,:)=1241-x2(1,:);
x1 = C \ x1; %  inv(C) * x = C \ x;
x2 = C \ x2;

C

pose=iterative_2_view(x1(1:2, :), x2(1:2, :), [1:num;1:num], 1:num);
pose_convert=cat(2, pose(1:3,1:3)',-pose(1:3,1:3)'*pose(1:3,4));
%pose_convert=cat(2, pose(1:3,1:3)',pose(1:3,4));
pose_convert(4, :) = 0; pose_convert(4, 4) = 1.0; 

P(1:3,4)=P(1:3,4)/norm(P(1:3,4));
% error
P(4,:) = 0; P(4,4) = 1.0;

% pose_error = P \ pose_convert;
% rd = (pose_error(1,1) + pose_error(2,2) + pose_error(3,3) - 1.0) * 0.5;
% r_error = acos(max(min(rd,1.0),-1.0));
% t_error = sqrt(pose_error(1,4)^2 + pose_error(2,4)^2 + pose_error(3,4)^2);

end

