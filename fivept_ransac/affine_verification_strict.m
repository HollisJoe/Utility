function [match_data]=affine_verification_strict(match_data, thres_spatial)

%thres_grad=1000000;
thres_grad=0.1;

spatial_s=1;


match_cur= match_data.matches_all(:,match_data.ind_likeli);
f11=match_data.f1(1:2, match_cur(1,:));
f22=match_data.f2(1:2, match_cur(2,:));
aff_ff=match_data.affine_all(:, match_data.ind_likeli);


match_set= match_data.matches_all(:,match_data.ind_chosen);
f1=match_data.f1(1:2, match_set(1,:));
f2=match_data.f2(1:2, match_set(2,:));
aff=match_data.affine_all(:, match_data.ind_chosen);

[Vec, T1, T2]=data2points_aff(f1, f2, aff);
%[Vec, T1, T2]=data2points_simple(f1, f2);
Vec=Vec';


[Vecc, T1, T2]=data2points_aff(f11, f22,aff_ff, T1, T2);
%[Vecc, T1, T2]=data2points_simple(f11, f22, T1, T2);
Vecc=Vecc';



f1=cat(1, f1(1:2,:), ones(1,size(f1,2)));
f2=cat(1, f2(1:2,:), ones(1,size(f2,2)));

f1=T1*f1;
f2=T2*f2;

f1=f1(1:2,:);
f2=f2(1:2,:);

f11=cat(1, f11(1:2,:), ones(1,size(f11,2)));
f22=cat(1, f22(1:2,:), ones(1,size(f22,2)));

f11=T1*f11;
f22=T2*f22;
f11=f11(1:2,:);
f22=f22(1:2,:);


T1
T2


if size(Vec,1)> 100
    Vec_pre_sample=Vec;

    [Vec]=cluster_sample(Vec', 100);
    Vec=Vec';
    
    size(Vec)
    [G]=G_compute_fast(Vec', Vec', 1);
    
    if size(f1,2)>300
        ind=randsample(size(f1,2), 300);
        f1=f1(:,ind);
        f2=f2(:,ind);
        Vec_pre_sample=Vec_pre_sample(ind,:);
    end;
    
    [G_all]=G_compute_fast(Vec_pre_sample', Vec', 1);
    
    [wx,ax0]=grad_desc_affine_correct(G, G_all,f1, f2(1,:), thres_grad);
    [wy,ay0]=grad_desc_affine_correct(G, G_all,f1, f2(2,:), thres_grad);
    
    
   
else
    [G]=G_compute_fast(Vec', Vec', 1);
    
    [G_all]=G_compute_fast(Vecc', Vec', 1);
    
    [wx,ax0]=grad_desc_affine_correct(G, G,f1, f2(1,:), thres_grad);
    [wy,ay0]=grad_desc_affine_correct(G, G,f1, f2(2,:), thres_grad);
    
  
    
end;



[inliers]=affine_inliers_research2(Vecc,Vec,f11, f22, wx, wy, ax0, ay0, thres_spatial);

verific=inliers;
match_data.ind_final=match_data.ind_likeli(verific);
match_data.ind_chosen=match_data.ind_final;

