function [accepet_binary, final_score]=final_decision(data)
num_pairs=length(data.pose);

% [accepet_binary]=accepts2binary(accepted);
% final_score=accepet_binary;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
repeated_score=1000*ones(num_pairs, num_pairs);
for i=1:num_pairs
    for j=1:num_pairs
        if data.m_e(i,j)>0
            repeated_score(i,j)=test_uniqueness(data.all_matches{i,j}, data.index{i,j});
        end;
    end;
end;
[accepet_binary]=m_e2binary(data.m_e, repeated_score);
final_score=accepet_binary;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




for i=1:num_pairs
    for j=i+1:num_pairs
        if accepet_binary(i,j)==1 ||accepet_binary(j,i)==1
            
            num_pass=0;
            
            for ii=1:num_pairs
                
                [est_a, est_b, est_c]=check_accepts_cheaper(data, i,j, ii, accepet_binary);
                
                if sum(sum(sum(abs(est_a))))>0 && sum(sum(sum(abs(est_b))))>0 && sum(sum(sum(abs(est_c))))>0
                    [rot_err1]=rotation_comparision(est_a, est_b);
                    rot_e=max(rot_err1);
                    [i j ii]
                    rot_e
                    [t_e]=translation_error(est_a, est_b, est_c);
                    t_e
                    if rot_e<2 %15 for weak calibration, 2 for strong calibration %&& t_e<0.2 %
                      %  num_pass=num_pass+1; % no triplet finding
                        
                        [est_a, est_b, est_c]=check_accepts(data, i,j, ii, accepet_binary);
                        if sum(sum(sum(abs(est_a))))>0 && sum(sum(sum(abs(est_b))))>0 && sum(sum(sum(abs(est_c))))>0 % has triplet match
                            if rot_e<2
                                num_pass=num_pass+10; %strong_accept
                            else                                
                                num_pass=num_pass+1; %weak_accept
                            end;
                        end;
                        
                    end;
                end;
            end;
            if accepet_binary(i,j)==1
                final_score(i,j)=num_pass;
            else
                final_score(j,i)=num_pass;
            end;
        end;
    end;
end;

% num_pass=0;
% for i=1:num_pairs
%     %try
%     [est_a, est_b, est_c]=check_accepts(data, i,12,13, accepet_binary);
%     if ~isempty(est_a) && ~isempty(est_b) && ~isempty(est_c)
%         [rot_err1]=rotation_comparision(est_a, est_b);
%         rot_e=max(rot_err1);
% i
% rot_e
%         [t_e]=translation_error(est_a, est_b, est_c);
%         t_e
%         if rot_e<10 %&& t_e<0.2
%             num_pass=num_pass+1;
%
%         end;
%     end;
%
%
% end;
% num_pass
% a=13;
% b=47;
% score=0;
% for i=1:num_pairs
%     %try
%     %[est_a, est_b, est_c]=check_accepts(data, i,10, 11, accepet_binary);
%     if i~=a && i~=b
%         [sm_a, sm_b, num_a, num_b]=check_accepts_cheap(data, a, b, i, accepet_binary);
% %     if i~=10 && i~=11
% %         [sm_a, sm_b, num_a, num_b]=check_accepts_cheap(data, 10, 11, i, accepet_binary);
%
%         if pass_mean(sm_a, 0.1) && num_a>100
%             score=score+1;
%             sm_a
%             i
%         end;
%         if pass_mean(sm_b, 0.1) && num_b>100
%             score=score+1;
%             sm_b
%             i
%         end;
% %         score=score+pass_mean(sm_a, 0.1);
% %         score=score+pass_mean(sm_b, 0.1);
%     end;
% end;
% score
%
end

function [r]=pass_mean(m, thres)
if isempty(m)
    r=0;
    return;
end;
mm=mean(m);
r=max(abs(m-mm))/mm;
if r<thres
    r=1;
else
    r=0;
end;
end

function [vals]=translation_error(est_a, est_b, est_c)
num=size(est_a,3);
vals=zeros(num,1);
for i=1:num
    a=norm(est_a(1:3,4,i)-est_b(1:3,4,i));
    b=norm(est_a(1:3,4,i)-est_c(1:3,4,i));
    c=norm(est_b(1:3,4,i)-est_c(1:3,4,i));
    vals(i)=max([a,b,c]);
    
end;
vals=max(vals);

end

function [vals]=rotation_comparision(est_a, est_b)
num=size(est_a,3);
vals=zeros(num,1);
for i=1:num
    vals(i)=rot_mag(est_a(1:3,1:3,i)'*est_b(1:3,1:3,i));
end;
vals=180*abs(vals)/pi;

end



function [accpet_binary]=m_e2binary(m_e, repeated_score)
% accept_binary is a NxN binary matrix indiicating which pairs to consider
% for a pair [i,j], [j,i], only one should be marked 1

num_views=size(m_e,1);
accpet_binary=zeros(num_views, num_views);

for i=1:num_views
    for j=i+1:num_views
        if m_e(i,j)>0 || m_e(j,i)>0 % there is a possible canidate
            
            if abs(repeated_score(i,j))<abs(repeated_score(j,i)) ||repeated_score(j,i)==0
                accpet_binary(i,j)=1;
                accpet_binary(j,i)=0;
            else
                accpet_binary(j,i)=1;
                accpet_binary(i,j)=0;
            end;
            
        end;
    end;
end;
end

function [accpet_binary]=accepts2binary(accepted)
% accept_binary is a NxN binary matrix indiicating which pairs to consider
% for a pair [i,j], [j,i], only one should be marked 1

num_views=size(accepted,1);
accpet_binary=zeros(num_views, num_views);

for i=1:num_views
    for j=i+1:num_views
        if accepted(i,j)>0 || accepted(j,i)>0 % there is a possible canidate
            if abs(accepted(i,j))<abs(accepted(j,i)) ||accepted(j,i)==0
                accpet_binary(i,j)=1;
                accpet_binary(j,i)=0;
            else
                accpet_binary(j,i)=1;
                accpet_binary(i,j)=0;
            end;
        end;
    end;
end;

end