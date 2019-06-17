function obj = extract_snp(fname,lines,legacy)

if nargin == 1
    legacy = 0; 
end

if ~legacy
    
    fid = fopen(fname); 

    c = textscan(fid,repmat('%s',[1,17]),'Delimiter','\t','Headerlines',1); 

    fclose(fid);
    
    obj.allele = c{6};
    obj.gatk_classify = c{12};
    obj.snpdb = c{16}; 
    obj.g1000db = c{17}; 
    obj.events = c{13}; 
    obj.genes =c{14};
    obj.chr = c{1}; 
    obj.start = c{2}; 
    obj.end = c{3}; 
    obj.ref = c{4}; 
    obj.obs = c{5}; 
    
    obj.allele = obj.allele(lines);
    obj.gatk_classify = obj.gatk_classify(lines);
    obj.snpdb = obj.snpdb(lines);
    obj.g1000db = obj.g1000db(lines);
    obj.events = obj.events(lines);
    obj.genes =obj.genes(lines);
    obj.chr = obj.chr(lines);
    obj.start = obj.start(lines);
    obj.end = obj.end(lines);
    obj.ref = obj.ref(lines);
    obj.obs = obj.obs(lines);
    
    
else
    
    fid = fopen(fname); 
    
    c = textscan(fid,repmat('%s',[1,16]),'Delimiter','\t','Headerlines',1); 

    fclose(fid);
    meta = c{10};
    obj.allele = cell(length(meta),1);
    
    for i = 1  : length(meta)
        if isempty(strfind(meta{i},'AF=0.50'))
            obj.allele{i} = 'hom';
        else
            obj.allele{i} = 'het' ;
        end
    end
    
    obj.gatk_classify = c{11};
    obj.snpdb = c{15}; 
    obj.g1000db = c{16}; 
    obj.events = c{12}; 
    obj.genes = c{13}; 
    obj.chr = c{1}; 
    obj.start = c{2}; 
    obj.end = c{3}; 
    obj.ref = c{4}; 
    obj.obs = c{5};
    
    obj.allele = obj.allele(lines);
    obj.gatk_classify = obj.gatk_classify(lines);
    obj.snpdb = obj.snpdb(lines);
    obj.g1000db = obj.g1000db(lines);
    obj.events = obj.events(lines);
    obj.genes =obj.genes(lines);
    obj.chr = obj.chr(lines);
    obj.start = obj.start(lines);
    obj.end = obj.end(lines);
    obj.ref = obj.ref(lines);
    obj.obs = obj.obs(lines);

end