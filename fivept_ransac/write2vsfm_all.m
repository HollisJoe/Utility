function []=write2vsfm_all(path_all, data)
%accepted=abs(accepted);
% num_pairs=length(data.pose);
% 
% repeated_score=1000*ones(num_pairs, num_pairs);
% for i=1:num_pairs
%     for j=1:num_pairs
%         if data.m_e(i,j)>0
%             repeated_score(i,j)=test_uniqueness(data.all_matches{i,j}, data.index{i,j});
%         end;
%     end;
% end;


new_match_file=strcat(path_all(1).folder,'\matching_clean.txt');

delete(new_match_file);

for i=1:size(data.m_e,1)
    for j=i+1:size(data.m_e,1)
        
        index_final=data.index{i,j};
        all_matches=data.all_matches{i,j};
        %m_e=data.m_e(i,j);

        %if accepted(i,j)>0 && accepted(i,j) <accepted(j,i)
        if ~isnan(data.m_e(i,j))   %&& repeated_score(i,j)<repeated_score(j,i)
            cur1=path_all(i).path;
            cur2=path_all(j).path;
            
            file_newmatch = fopen(new_match_file,'at');
            fprintf(file_newmatch, '%s\n', cur1);
            fprintf(file_newmatch, '%s\n', cur2);
            fclose(file_newmatch);
            
            dlmwrite(new_match_file, length(index_final), '-append');
            dlmwrite(new_match_file, all_matches(1,index_final)-1, '-append', 'delimiter',' ');
            dlmwrite(new_match_file, all_matches(2,index_final)-1, '-append', 'delimiter',' ');
            
            file_newmatch = fopen(new_match_file,'at');
            fprintf(file_newmatch, '\n');
            fclose(file_newmatch);
            
        end;
    end;
end;