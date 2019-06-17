function [ge_collapsed,gene_symbols] = collapse2genes(ge_mat,gn,chip)


error('do not use')
[~,~,j] = intersect_ord(gn,chip.Probe_Set_ID); 

gene_symbols = unique_ord(chip.Gene_Symbol(j)); 

ge_collapsed = zeros(length(gene_symbols),size(ge_mat,2)); 

parfor ii = 1 : length(gene_symbols)
    ge_collapsed(ii,:) = max(ge_mat(strcmp(gene_symbols{ii},...
        chip.Gene_Symbol(j)),:),[],1); 
end