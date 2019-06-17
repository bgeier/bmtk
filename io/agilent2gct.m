function [ge_mat,gn,gd,sid] = agilent2gct(fname)

data = parse_frame(fname); 
num_samples = length(fieldnames(data))-2 ; 
% num_probes = length(gn); 

tmp = zeros(length(data.ProbeID),num_samples); 
sid = fieldnames(data); 
sid(1:2) = [];
parfor i = 1 : num_samples
    tmp(:,i) = str2double(getfield(data,{1},sid{i})) ;  
end
% h = waitbar(0,'Duplicate Probe Summarizing...'); 

drop = any(isnan(tmp),2) ;
data.ProbeID(drop) = [];
[gn,cnts] = uniqc(data.ProbeID); 
[~,L] = intersect_ord(data.ProbeID,gn); 
gd = data.GeneSymbol(L); 
ge_mat = zeros(length(gn),num_samples); 

% gn(drop) = [];
tmp(drop,:) = [];
% ge(drop,:) = [];
% cnts(drop) = [];

% ix = find(cnts>1); 
parfor i = 1:size(ge_mat,1)
    ge_mat(i,:) = mean(tmp(strcmp(gn{i},data.ProbeID),:),1); 
%     waitbar(i/num_probes,h); 
end
% close(h); 