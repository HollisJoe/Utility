function [inliers]=ransac_subsample(f1, f2, matches_many, K1_i, K2_i, ransac_thres)

subsampled=0;

[x1]=calib_data(f1(1:2, matches_many(1,:)), K1_i);
[x2]=calib_data(f2(1:2, matches_many(2,:)), K2_i);

if length(matches_many)>1000
    sam=randsample(length(matches_many),1000);
    x11=x1(:,sam);
    x22=x2(:,sam);
    subsampled=1;
else
    x11=x1;
    x22=x2;
end;

[E, inliers]=ransac_economy(x11', x22', ransac_thres);
if isempty(E)
    return;
end;
    
if subsampled==1
    F=E';
    
    Fp1 = F*x1;
    Ftp2 = F'*x2;
    p2tFp1=sum(x2.*(F*x1),1);    
    d =  p2tFp1.^2 ./ ...
        (Fp1(1,:).^2 + Fp1(2,:).^2 + Ftp2(1,:).^2 + Ftp2(2,:).^2);
    sd=sqrt(d);
    inliers = find(abs(sd) < ransac_thres);    
    
end;