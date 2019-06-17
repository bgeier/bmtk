function [stat_set, keeper ]  = parse_fobstats(fname)

fid = fopen(fname,'r'); 

hd = fgetl(fid); 
flag = zeros(1,length(hd)); 
for i = 1 : length(flag)
    if isspace(hd(i))
        flag(i) = 1 ; 
    end
end
ix = find(flag); 
keeper = cell(sum(flag)+1,1); 
keeper{1} = hd(1:ix(1)-1) ; 
for i = 1 : length(keeper) - 2
    keeper{i+1} = hd(ix(i)+1:ix(i+1)-1); 
end
keeper{end} = hd(ix(end)+1:end); 
fclose(fid); 
fid = fopen(fname,'r'); 

keeper{end} = hd(ix(end)+1:end); 
num_fields = length(keeper); 
c = textscan(fid,repmat('%s',[1,num_fields]),'Delimiter','\t','headerlines',1); 
stat_set = struct('name','','vals',''); 
change2num = {'F','Rsquare','Coef_a','Coef_b','Coef_c','RMSE','Truncated_genes'};
for i = 1 : num_fields
    stat_set(i).name = keeper{i}; 
    if any(strcmp(keeper{i},change2num))
        stat_set(i).vals = str2num(char(c{i})); 
    else
        stat_set(i).vals = c{i}; 
    end
end
	
fclose(fid); 