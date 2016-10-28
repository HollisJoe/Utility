function [o]=rot_2_angle2(R)
k=dcm2quat(R);
o=sign(k(1))*k(2:end)';

