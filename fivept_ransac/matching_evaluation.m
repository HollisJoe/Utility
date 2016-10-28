function []=matching_evaluation(evaluation_data, evaluation_data_bf)
%evaluation_data=struct('rot_error', [], 'trans_error', [], 'pairs', [], 'rot_mag', [], 'trans_mag', []);
close all

num_pairs=length(evaluation_data);
p=zeros(num_pairs, 1);

p_bf=zeros(num_pairs, 1);

r_mag=zeros(num_pairs, 1);
t_mag=zeros(num_pairs, 1);

for i=1: num_pairs;
    r_mag(i)=abs(evaluation_data(i).rot_mag);
    t_mag(i)=abs(evaluation_data(i).trans_mag);
    
    
    
    p(i)=1-evaluation_data(i).percent;
    if isempty(evaluation_data_bf(i).percent) 
        p_bf(i)=0;
    else
        p_bf(i)=1-evaluation_data_bf(i).percent;    
    end;
    
    
    
end;


figure
ours_rotation=stability_plot(p, r_mag, '-bd');
hold on

CODE_rotation=stability_plot(p_bf, r_mag, '--rd');

% set(gca,'FontWeight','bold')
% xlhand = get(gca,'xlabel');
% ylhand = get(gca,'ylabel');
set(gca,'FontWeight','bold')
set(gca,'FontSize',25)
% set(xlhand,'string','Error in degrees','fontsize',20, 'fontweight','b')
% set(ylhand,'string','Stability bound','fontsize',20, 'fontweight','b')
saveas(gcf, 'test', 'pdf') 

% 
% DataTable=cell(4, length(ours_rotation));
% 
% DataTable{1,1}='Algo';      DataTable{1,2}='Av. Precision 7';       DataTable{1,3}='Av. Matches';           DataTable{1,4}='Av. Time';                  DataTable{1,5}='Max. Time';         DataTable{1,6}='Total Failures';                  
% DataTable{2,1}='Ours';                DataTable{2,2}=mp_bd;                   DataTable{2,3}=mean(n_bd);              DataTable{2,4}=mean(t_bd(I_bd));            DataTable{2,5}=max(t_bd);           DataTable{2,6}=length(t_bd)-length(I_bd);    
% DataTable{3,1}='CODE';      DataTable{3,2}=mp_pma;                  DataTable{3,3}=mean(n_pma);             DataTable{3,4}=mean(t_pma(I_pma));          DataTable{3,5}=max(t_pma);          DataTable{3,6}=length(t_pma)-length(I_pma);
% 

ours_rotation

CODE_rotation


    

hold off



return;

end

function [vals]=stability_plot(r_e, r_mag, type)

r_e=abs(r_e);
r_mag=abs(r_mag);

increments=0.01;
runner=1;
plots=[];
x=[];
for i=0:increments:0.3
    mask=r_e>i;
    val=min(r_mag(mask));
    val
    
    if isempty(val)
        plots(runner)=max(r_mag);
    else
        plots(runner)=val;
        
    end;
    x(runner)=i;
    runner=runner+1;
end;


vals=cat(1, x, plots);
    
plot(x, plots, type, 'LineWidth',2);


end
