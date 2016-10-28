function [C]=cluster_sample(x, num)

total=size(x,2);

if total >5*num
    
    if total > 500
        ind=randsample(total, 500);
        x=x(:,ind);
        
    end;
    [~,C]= kmeans(x',num, 'emptyaction','singleton');
    mask=isnan(C);
    C(mask)=[];
    C=C';
    
else
    if num>=total
        C=x;
    else
        ind=randsample(total, num);
        C=x(:,ind);
        
    end;

end;
