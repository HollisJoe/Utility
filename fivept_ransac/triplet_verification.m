function [passed_sec]=triplet_verification(data)
num_views=size(data.m_e,1);

[binary_pass]=potential_pairs(data);
passed_sec=zeros(num_views, num_views);


k=12,find(binary_pass(:,k)),find(binary_pass(k,:)')
return;

%for i=1:num_views-2
for i=12:12
    for j=i+1:num_views-1
        for k=j+1:num_views
            [pair1, pair2, pair3]=find_pairs(binary_pass, i,j,k);
            [est_a, est_b, est_c]=check_accepts(data, i, j, k, binary_pass);
%             

           if ~isempty(est_a) && ~isempty(est_b) && ~isempty(est_c)
           %if ~isempty(pair1) && ~isempty(pair2) && ~isempty(pair3)

                passed_sec(pair1(1), pair1(2))=passed_sec(pair1(1), pair1(2))+1;
                passed_sec(pair2(1), pair2(2))=passed_sec(pair2(1), pair2(2))+1;
                passed_sec(pair3(1), pair3(2))=passed_sec(pair3(1), pair3(2))+1;
                
                [i j k]

                
                
%                 [rot_err1]=rotation_comparision(est_a, est_b);
%                 rot_e=max(rot_err1);
%                 [i j k]
%                 rot_e
%                 [t_e]=translation_error(est_a, est_b, est_c);
%                 t_e
%                 if rot_e<15 %&& t_e<0.2
%                     num_pass=num_pass+1;
%                     
%                 end;
            end;
            
        end;
    end;
    
end
end

function [pair1, pair2, pair3]=find_pairs(binary, i,j,k)

pair1=[];
pair2=[];
pair3=[];

if binary(i,j)==1
    pair1=[i,j];
end;
if binary(j,i)==1
    pair1=[j,i];
end;

if binary(i,k)==1
    pair2=[i,k];
end;
if binary(k,i)==1
    pair2=[k,i];
end;

if binary(k,j)==1
    pair3=[k,j];
end;
if binary(j,k)==1
    pair3=[j,k];
end;


end

function [binary_pass]=potential_pairs(data)

num_views=size(data.m_e,1);

binary_pass=zeros(num_views, num_views);
for i=1:num_views
    for j=i+1:num_views
        
        uniq1=1000;
        uniq2=1000;
        
        if ~isnan(data.m_e(i,j))
            uniq1=test_uniqueness(data.all_matches{i,j},data.index{i,j});
        end;
        if ~isnan(data.m_e(j,i))
            uniq2=test_uniqueness(data.all_matches{j,i},data.index{j,i});
        end;
        
        if uniq1<1 || uniq2<1
            if uniq1<uniq2
                binary_pass(i,j)=1;
            else
                binary_pass(j,i)=1;
            end;
        end;
    end;
end;


end
