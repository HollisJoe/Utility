function [accepted]=accepted_pairs(data)

num_pairs=size(data.index,1);
accepted=zeros(num_pairs, num_pairs);

trust=data.m_e;
for i=1:num_pairs
    for j=i+1:num_pairs
        if~isnan(trust(i,j))
            if length(data.index{i, j})>100
                %uniq=test_uniqueness(data.all_matches{i,j},data.index{i, j});
                %trust(i,j)=uniq*uniq*trust(i,j)/sqrt(length(data.index{i,j}));
                trust(i,j)=trust(i,j)/length(data.index{i,j})^2;

                trust(j,i)=trust(i,j);
            else
                trust(i,j)=1000;
                trust(j,i)=trust(i,j);
            end;
        end;
    end;
end;

isnan(trust);
trust(isnan(trust))=1000;
trust=sparse(trust);
trust_store=trust;

[accepted, trust]=spaning_tree_best(trust, accepted);
[min_err]=min_vals(accepted, data, trust_store);
[accepted, trust]=spaning_tree_best(trust, accepted);
[accepted, trust]=spaning_tree_best(trust, accepted);
%[accepted, trust]=spaning_tree_best(trust, accepted);



% make it upper triangular
for i=1:size(accepted,1)
    for j=1:size(accepted,2)
        if accepted(i,j)==1
            [ind]=sort([i,j]);
            accepted(ind(1), ind(2))=1;
            accepted(ind(2), ind(1))=0;
            
        end;
    end;
end;

[accepted]=find_more(accepted, min_err, data, trust_store);

for i=1:size(accepted,1)
    for j=1:size(accepted,2)
        if accepted(i,j)==1 && trust_store(i,j)<1000
            
            [ind]=sort([i,j]);
            
            [wrong_ratio]=test_uniqueness(data.all_matches{ind(1), ind(2)},data.index{ind(1), ind(2)});
            
            if wrong_ratio> 0.2
                accepted(i,j)=-wrong_ratio;
            else
                accepted(i,j)=wrong_ratio;
            end;
        else
            accepted(i,j)=0;
            %accepted(j,i)=0;
        end;        
    end;
end;


end

function [accepted, trust]=spaning_tree_best(trust, accepted)

[Tree, ~] = graphminspantree(trust);

[i,j,s] = find(Tree);
ind=find(Tree);
accepted(ind)=1;

for k=1:length(i)
    trust(i(k), j(k))=1000;
    trust(j(k), i(k))=1000;
    
end;

end


function [min_err]=min_vals(accepted, data, trust)

num_cams=size(data.index,1);

min_err=zeros(num_cams,1);
for i=1:num_cams
    min_m_e=100000;
    for j=1:num_cams
        if accepted(i,j)==1 || accepted(j,i)==1%&& data.m_e(i,j)<min_m_e
            score1=trust(i,j);
            score2=trust(j,i);
            score=min(score1, score2);
            
            if score<min_m_e
                min_m_e=score;
                
            end;
        end;
    end;
    
    min_err(i)=min_m_e;
end;

end

function [accepted]=find_more(accepted, min_score, data, trust)

num_cams=size(data.index,1);

for i=1:num_cams
    for j=i+1:num_cams
        score=trust(i,j);
        if score<min_score(i)*1.4
            accepted(i,j)=1;
        end;
    end;
end;

end