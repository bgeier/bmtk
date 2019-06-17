function psr_struct = parse_psr(fname,delim)
% PARSE_PSR     Parse Partek Genomic Segmentation Result
% 
% Author: Brian Geier, PPTP 2011

if nargin == 1
    delim = '%s%f%f%s%s%s%f%f%f%f%s%s%f';
end
fid = fopen(fname); 
c = textscan(fid,delim,'Delimiter','\t'); 
fclose(fid); 
psr_struct.chromosome = c{1}; 
psr_struct.start = c{2}; 
psr_struct.end = c{3} ;
psr_struct.cytoband = c{4}; 
psr_struct.sample_id = c{5}; 
psr_struct.copy_number = c{6}; 
psr_struct.length = c{7}; 
psr_struct.mean = c{8}; 
psr_struct.num_markers = c{9}; 
psr_struct.p_value = c{10}; 
psr_struct.overlapping_features = c{11}; 
psr_struct.nearest_feature = c{12}; 
psr_struct.distance2nearest_feature = c{13}; 