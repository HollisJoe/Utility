function [Z, s_e, problem]=confidence10(pose, P1, P2, pix)


if size(P1, 1)==2
    P1=cat(1, P1, ones(1, size(P1,2)));
end;


if size(P2, 1)==2
    P2=cat(1, P2, ones(1, size(P2,2)));
end;


[e]=signed_score(pose, P1, P2);
m_e=mean(abs(e));
%s_e=sqrt(var(abs(e)));
s_e=1.48*median(abs(e));

Q1 = P1';
Q2 = P2';

Q = [Q1(:,1).*Q2(:,1) , ...
    Q1(:,2).*Q2(:,1) , ...
    Q1(:,3).*Q2(:,1) , ...
    Q1(:,1).*Q2(:,2) , ...
    Q1(:,2).*Q2(:,2) , ...
    Q1(:,3).*Q2(:,2) , ...
    Q1(:,1).*Q2(:,3) , ...
    Q1(:,2).*Q2(:,3) , ...
    Q1(:,3).*Q2(:,3) ] ;


[U,S,V] = svd(Q,0);
EE = V(:,9);
EE = reshape(EE,3,3)';

[e9]=signed_score(EE, P1, P2);

EE = V(:,8);
EE = reshape(EE,3,3)';

[e8]=signed_score(EE, P1, P2);

if abs(mean(abs(e8)))> abs(mean(abs(e9)))
    e=e8;
else
    e=e9;
end;



me_t=mean(abs(e));

length(e)
Z=(me_t-m_e)/(s_e/sqrt(length(e)));
Z=Z/10;
Z
%Z=(me_t-m_e)/(s_e)
me_t

m_e

s_e

me_t-m_e
1-normcdf(abs(Z),0,1)


if Z< 1.5 || s_e> 3*pix % 3 pixel error
    'value may be wrong'
    problem=1;
else
    problem=0;
end;

return;
