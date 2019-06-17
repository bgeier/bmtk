function evf_struct = parse_evf(fname)
% Parser for *.exonic_variant_function  ANNOVAR parser
% Author: Brian Geier, 2011

fid = fopen(fname,'r'); 

evf_struct = struct('input_line','','variant_type','',...
    'variant_meta','','chromosome','','start_position','',...
    'end_position','','reference','','observed','','snv_type',''); 

c = textscan(fid,repmat('%s',[1,9]),'Delimiter','\t'); 

fclose(fid); 

evf_struct.input_line = c{1}; 
evf_struct.variant_type = c{2};
evf_struct.variant_meta = c{3};
evf_struct.chromosome = c{4}; 
evf_struct.start_position = str2double(c{5}); 
evf_struct.end_position = str2double(c{6}); 
evf_struct.reference = c{7}; 
evf_struct.observed = c{8} ; 
evf_struct.snv_type = c{9} ; 

allowed_variants = {'frameshift deletion'
    'frameshift insertion'
    'frameshift substitution'
    'nonframeshift deletion'
    'nonframeshift insertion'
    'nonframeshift substitution'
    'nonsynonymous SNV'
    'stopgain SNV'
    'stoplost SNV'
    'synonymous SNV'};

idx = zeros(length(evf_struct.input_line),length(allowed_variants)); 
for i = 1 : length(allowed_variants)
    idx(:,i) = strcmp(allowed_variants{i},evf_struct.variant_type); 
end

idx = sum(idx,2); 
idx = ~logical(idx); 

evf_struct.input_line(idx) = [];
evf_struct.variant_type(idx) = [];
evf_struct.variant_meta(idx) = [];
evf_struct.chromosome(idx) = []; 
evf_struct.start_position(idx) = []; 
evf_struct.end_position(idx) = []; 
evf_struct.reference(idx) = []; 
evf_struct.observed(idx) = [] ; 
evf_struct.snv_type(idx) = [] ; 