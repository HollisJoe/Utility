function [ F1,D1,F2,D2 ] = runASIFT( I1gray, I2gray )
%RUNASIFT Summary of this function goes here
%   Detailed explanation goes here
% I1gray should be float gray image, = image';
I1gray_s = single(I1gray);
I2gray_s = single(I2gray);

[F1,D1] = mexASIFT(I1gray_s');
[F2,D2] = mexASIFT(I2gray_s');
end

