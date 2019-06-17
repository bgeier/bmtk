function compare_tbls(varargin)

toolName = mfilename ; 
pnames = {'-table_dir','-out','-drop_dbsnp'};
dflts = {pwd,pwd,true};

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 

files = dir(fullfile(arg.table_dir,'*.table')); 
% sample_struct = struct('data','','name','','header','');

tolerated_events = {'UTR3','UTR5','UTR5;UTR3','downstream','intergenic',...
    'intronic','ncRNA','synonymous SNV','upstream','upstream;downstream'}; 
genes = [];

for i = 1 : length(files)
    print_str(['Loading..',pullname(files(i).name)]); 
    [data,header] = parse_frame(fullfile(arg.table_dir,files(i).name)); 
    keep = strcmp('High',data.Confidence);
    drop = zeros(length(data.Confidence),length(tolerated_events)); 
    for j = 1 : size(drop,2)
        drop(strcmp(tolerated_events{j},data.Event),j)=1; 
    end
    if arg.drop_dbsnp
        drop = any(drop,2) | (~keep) | (~isnan(str2double(data.KGFreq))) | ...
            (~strcmp('.',data.dbSNP)) ; 
    else
        drop = any(drop,2) | (~keep) | (~isnan(str2double(data.KGFreq))); 
    end
    for j = 1 : length(header)
        data.(header{j})(drop) = [];
    end

    num_lines = length(data.Sample); 
    fid = fopen(fullfile(otherwkdir,[pullname(files(i).name),'_dh.txt']),'w'); 
    for j = 1 : length(header) -1 
        fprintf(fid,'%s\t',header{j}); 
    end
    fprintf(fid,'%s\n',header{end}); 
    h = waitbar(0,'Writing damaging file'); 
    for j = 1 : num_lines
        for k = 1 : length(header)-1
            fprintf(fid,'%s\t',data.(header{k}){j}); 
        end
        fprintf(fid,'%s\n',data.(header{end}){j}); 
        waitbar(j/num_lines,h); 
    end
    fclose(fid); 
    close(h); 
    genes = [genes ; data.NearestGene]; 
end
[gd,ge] = uniqc(genes); 

subs = zeros(length(gd),length(files)); 
for i = 1 : length(files)
    print_str(['Processing..',pullname(files(i).name)]); 
    [data,header] = parse_frame(fullfile(arg.table_dir,files(i).name)); 
    keep = strcmp('High',data.Confidence);
    drop = zeros(length(data.Confidence),length(tolerated_events)); 
    for j = 1 : size(drop,2)
        drop(strcmp(tolerated_events{j},data.Event),j)=1; 
    end
    if arg.drop_dbsnp
        drop = any(drop,2) | (~keep) | (~isnan(str2double(data.KGFreq))) | ...
            (~strcmp('.',data.dbSNP)) ; 
    else
        drop = any(drop,2) | (~keep) | (~isnan(str2double(data.KGFreq))); 
    end
    for j = 1 : length(header)
        data.(header{j})(drop) = [];
    end
    [~,L] = intersect_ord(gd,data.NearestGene); 
    subs(L,i) = 1; 
end
    
ge = [ge, subs]; 
header = {'VariantCount'}; 
for i = 1 : length(files)
    header{i+1} = pullname(files(i).name); 
end

mkgct(fullfile(otherwkdir,'multisample_dh.gct'),ge,gd,gd,header,1);
