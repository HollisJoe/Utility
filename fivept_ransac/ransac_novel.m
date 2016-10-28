function [E_best, bestInliers]=ransac_novel(p1, p2, thres)
% 
% s = RandStream('mcg16807','Seed',0);
% RandStream.setGlobalStream(s);

num_iter=500;

num_inliers=0;

num=size(p1,1);

num_sample=min(num,20);

p1=p1';
p2=p2';
E_best=zeros(3,3);
error=Inf;
for j=1:num_iter
    
    
    s=randsample(num,num_sample);
   
    [E] = compute_E2(p1(:,s), p2(:,s));
    
    for i=1:size(E,3)
        F=squeeze(E(:,:,i))';
        p2tFp1=sum(p2.*(F*p1),1);
%         p2tFp1 = zeros(1,length(p1));
%         for n = 1:length(p1)
%             p2tFp1(n) = p2(:,n)'*F*p1(:,n);
%         end
        Fp1 = F*p1;
        Ftp2 = F'*p2;
        d =  p2tFp1.^2 ./ ...
            (Fp1(1,:).^2 + Fp1(2,:).^2 + Ftp2(1,:).^2 + Ftp2(2,:).^2);
        sd=sqrt(d);
        de=median(sd);
        if de<error   % Record best solution
            error=de;
            E_best = F';
            bestInliers = find(sd< 2*1.48*de);
        end
       % inliers = find(abs(d) < thres);
        
        
%         if length(inliers) > num_inliers   % Record best solution
%             num_inliers = length(inliers);
%             E_best = F';
%             bestInliers = inliers;
%         end
    end;
    
end;

[E] = calibrated_fivepoint_mult(p1(:,bestInliers), p2(:,bestInliers));
%[E] = compute_E2(p1(:,bestInliers), p2(:,bestInliers));

error=Inf;
for i=1:size(E,3)
    F=squeeze(E(:,:,i))';
    p2tFp1=sum(p2.*(F*p1),1);

%     p2tFp1 = zeros(1,length(p1));
%     for n = 1:length(p1)
%         p2tFp1(n) = p2(:,n)'*F*p1(:,n);
%     end
    Fp1 = F*p1;
    Ftp2 = F'*p2;
    d =  p2tFp1.^2 ./ ...
        (Fp1(1,:).^2 + Fp1(2,:).^2 + Ftp2(1,:).^2 + Ftp2(2,:).^2);
    
    de=median(sqrt(d));
    
    
    if de< error   % Record best solution
        error=de;
        E_best = F';
        %bestInliers = inliers;

    end
end;


