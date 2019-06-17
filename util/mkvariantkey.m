function [key,idx] = mkvariantkey(data,variant_type)

key = [char(data.chromosome),char(num2str((data.start))),char(num2str(data.end)),...
    char(data.ref),char(data.obs),char(data.allele)];
key = strrep(cellstr(key),' ','');
    
switch variant_type
    case 'snp'
        drop = strcmp('intergenic',data.events) | ...
            strcmp('intronic',data.events) | ... 
            ~strcmp('PASS',data.gatk_classify) ; 
    case 'indel'
        drop = strcmp('intergenic',data.events) | ...
            strcmp('intronic',data.events) ;
end
key(drop)= [];
idx = find(~drop); 