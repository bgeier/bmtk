function qmr_struct = parse_qmr(fname)
% PARSE_QMR     Parse Query MakeFile Results
% see also query_mkfile, query_cnv
% 
% Author: Brian Geier, 2011 PPTP

delim = '%s%f%f%s%s%s%f%f%f%f%s%f%f%s%s%s';
fid = fopen(fname); 
c = textscan(fid,delim,'Delimiter','\t','Headerlines',1); 
fclose(fid); 

qmr_struct.chromosome = c{1}; 
qmr_struct.start = c{2}; 
qmr_struct.end = c{3}; 
qmr_struct.cytoband = c{4}; 
qmr_struct.sample_id = c{5}; 
qmr_struct.copy_number = c{6}; 
qmr_struct.length = c{7}; 
qmr_struct.mean = c{8}; 
qmr_struct.num_markers = c{9}; 
qmr_struct.p_value = c{10}; 
qmr_struct.gene = c{11}; 
qmr_struct.gene_length = c{12}; 
qmr_struct.pct_overlap = c{13}; 
qmr_struct.histology = c{14}; 
qmr_struct.sample_source = c{15}; 
qmr_struct.sample_line = c{16}; 

