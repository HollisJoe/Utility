function [TT]=hat(T)

TT=zeros(3,3);

TT(1,2)=-T(3);
TT(1,3)=T(2);
TT(2,1)=T(3);
TT(2,3)=-T(1);
TT(3,1)=-T(2);
TT(3,2)=T(1);