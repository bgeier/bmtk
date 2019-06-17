function [ge_genelevel,gene_symbols,chip_ref] = collapseArray2Gene(ge_probelevel,gn,chip)

[~,i,j] = intersect_ord(chip.Probe_Set_ID,gn);
ge_probelevel = ge_probelevel(j,:) ; 
% gn = gn(j); 

genes = chip.Gene_Symbol(i);
[gene_symbols,chip_ref] = unique_ord(genes);
chip_ref = i(chip_ref); 
ge_genelevel = zeros(length(gene_symbols),size(ge_probelevel,2));

parfor i = 1 : length(gene_symbols)
    ge_genelevel(i,:) = max(ge_probelevel(strcmp(gene_symbols{i},genes),:)...
        ,[],1);
end