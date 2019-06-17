function data = parse_variant(fname,type,legacy)

if nargin == 2
    legacy = 0 ; 
end

switch type
    case 'snp'
        
        if ~legacy
            
            fid = fopen(fname);
            c = textscan(fid,repmat('%s',[1,17]),'Delimiter','\t',...
                'Headerlines',1);
            fclose(fid); 

            data.chromosome = c{1}; 
            data.start = single(str2double(c{2})); 
            data.end = single(str2double(c{3}));  
            data.ref = c{4}; 
            data.obs = c{5}; 
            data.allele = c{6};
            data.phred = single(str2double(c{7})); 
            data.read_depth = single(str2double(c{8})); 
            data.rms_mapping_quality = single(str2double(c{9})); 
            data.quality_by_depth = single(str2double(c{10})); 
            data.gatk_meta = c{11}; 
            data.gatk_classify = c{12};
            data.events = c{13}; 
            data.genes =c{14}; 
            data.segdup = c{15}; 
            data.snpdb = c{16}; 
            data.g1000db = c{17};
        end
        
    case 'indel'
        
        if ~legacy
            
            fid = fopen(fname); 
            c = textscan(fid,repmat('%s',[1,16]),'Delimiter','\t',...
                'Headerlines',1); 
            fclose(fid);

            data.chromosome = c{1}; 
            data.start = single(str2double(c{2})); 
            data.end = single(str2double(c{3}));  
            data.ref = c{4}; 
            data.obs = c{5}; 
            data.allele = c{6};
            data.phred = single(str2double(c{7})); 
            data.read_depth = single(str2double(c{8})); 
            data.reads_supporting_INDEL = single(str2double(c{9})); 
            data.rms_mapping_quality = single(str2double(c{10})); 
            data.gatk_meta = c{11}; 
            data.events = c{12}; 
            data.genes =c{13}; 
            data.segdup = c{14} ; 
            data.snpdb = c{15};
        end
        
    otherwise
        error('check type')
        
end


