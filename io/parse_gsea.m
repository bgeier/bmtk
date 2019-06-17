function gsea_rpt = parse_gsea(fname)

fid = fopen(fname,'r'); 

gsea_rpt = struct('fname','','header','','fields',''); 

check_header = fgetl(fid); 

fclose(fid); 

fid = fopen(fname,'r'); 

gsea_rpt.fields = textscan(fid,'%s%s%f%f%f%f%f%f%f%s','Delimiter','\t',...
    'Headerlines',1);

fclose(fid); 


set_header = {'NAME','GS<br> follow link to MSigDB','SIZE',...
    'ES','NES','NOM p-val','FDR q-val','FWER p-val','RANK AT MAX',...
    'LEADING EDGE'}; 

ix = zeros(1,length(set_header)); 
for i = 1 : length(ix)
    ix(i) = min(strfind(check_header,set_header{i})) ; 
end

if any( sort(ix) ~= ix )
    error('File header not consistent with settings...')
end

gsea_rpt.header = set_header ; 
gsea_rpt.fname = fname ; 

field_names = {'gene_set','desc','size','es','nes','nom_pval',...
    'fdr_qval','fwer_pval','rank_at_max','leading_edge'}; 

for i = 1 : length(set_header)
    eval([' gsea_rpt.',field_names{i},' = gsea_rpt.fields{',num2str(i),'};'])
end