function indeltex(varargin)
% SNPTEX    Routine for compiling *tex report given multi-sample SNP table
% 
% see also merge_tables

toolName = mfilename ; 
pnames = {'-table','-out','-vignettes'}; 
 
dflts = {'',pwd,true}; 

arg = getargs2(pnames,dflts,varargin{:}); 

print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out, toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid);

h = findNewHandle(); 

fid = fopen(arg.table); 
header = fgetl(fid); 
t = textscan(header,'%s','Delimiter','\t');
header = t{1}; 
ncol = length(header); 
c = textscan(fid,repmat('%s',[1,ncol]),'Delimiter','\t'); 
fclose(fid); 

data = struct('table',pullname(arg.table)); 
for i = 1 : length(header)
    data = setfield(data,header{i},c{i}); 
end
clear c

nsamples = ncol-15; 
sample_idx = zeros(ncol,1); 
sample_idx(end-(nsamples-1):end) = 1; 
sample_idx = find(sample_idx); 
covariates = {'rms_mapping_quality','reads_supporting_INDEL','read_depth'}; 
drop = str2double(getfield(data,'read_depth'))<10; 
colors = mkcolorspec(nsamples); 
font_size = 11; 
if arg.vignettes
    for i = 1 : length(covariates)
        figure
        hold on 
        for j = 1 : nsamples
            look = ~strcmp('yes',getfield(data,header{sample_idx(j)})); 
            y = str2double(getfield(data,covariates{i})); 
            y(look | drop) = [];
            [f,x] = ecdf(y); 
            stairs(x,f,colors{j},'LineWidth',1.4)
            xlabel(['X:',dashit(covariates{i})],'FontSize',font_size)
            ylabel('F(X)')
            title('Multi-Sample Variant Quality','FontSize',font_size)
            set(gca,'FontSize',font_size)
            set(gcf,'Name',dashit(covariates{i})); 
            grid on ; 
        end
    end

    mkdir(otherwkdir,'plots')

    for i = h : findNewHandle - 1
        figure(i)
        orient landscape
        saveas(i,fullfile(otherwkdir,'plots',get(i,'Name')),'pdf'); 
        close(i); 
    end
end

drop = ~strcmp('novel',data.snpdb) ;
for i = 1 : length(header)
    data = setfield(data,{1},header{i},{drop},[]);
end
yes_damage = {'frameshift deletion','frameshift insertion',...
    'stopgain SNV','stoploss SNV'};
maybe_damage = {'splicing','ncRNA'};
unlikely_damage = {'UTR3','UTR5','downstream','upstream',...
    'upstream;downstream','UTR3;UTR5','UTR5;UTR3'};
no_damage = {'nonframeshift deletion','nonframeshift insertion'};

genes = cell(length(data.allele),1); 
for i = 1 : length(genes)
    idx = find(data.genes{i}==':'); 
    if isempty(idx)
        genes{i} = data.genes{i};
        continue
    end
    t = data.genes{i}; 
    genes{i} = t(2:idx(1)-1); 
end
uniq_genes = unique_ord(genes); 

num_genes = length(uniq_genes); 

idx = cell(num_genes,nsamples); 

indicator_idx = zeros(size(idx)); 
for j = 1 : nsamples
    look = strcmp('yes',getfield(data,header{sample_idx(j)})); 
    print_str(['Scanning: ',header{sample_idx(j)}]); 
    h = waitbar(0,'computing per gene') ;
    for i = 1 : num_genes

        gene_idx = strcmp(uniq_genes{i},genes); 
        
        if ~isempty(intersect(data.events(look & logical(gene_idx)),...
                yes_damage))
            idx{i,j}='yes'; 
            indicator_idx(i,j) = 4; 
        elseif ~isempty(intersect(data.events(look & logical(gene_idx)),...
                maybe_damage))
            idx{i,j}='maybe'; 
            indicator_idx(i,j) = 3; 
        elseif ~isempty(intersect(data.events(look & logical(gene_idx)),...
                unlikely_damage))
            idx{i,j}='unlikely';
            indicator_idx(i,j) = 2; 
        elseif ~isempty(intersect(data.events(look & logical(gene_idx)),...
                no_damage))
            idx{i,j}='no'; 
            indicator_idx(i,j) = 1; 
        elseif isempty(data.events(look & logical(gene_idx)))
            idx{i,j}='missing';
            indicator_idx(i,j) = 0; 
        else
            idx{i,j} = 'unknown'; 
            indicator_idx(i,j) = -1; 
        end
        waitbar(i/num_genes,h); 
        
    end
    close(h); 
end


fid = fopen(fullfile(otherwkdir,'summarization.txt'),'w'); 
fprintf(fid,'%s\t','Gene Symbol'); 
for i = 1 : nsamples -1
    fprintf(fid,'%s\t',header{sample_idx(i)}); 
end
fprintf(fid,'%s\n',header{sample_idx(i)}); 
for i = 1 : num_genes
    fprintf(fid,'%s\t',uniq_genes{i}); 
    for j = 1 : nsamples -1
        fprintf(fid,'%s\t',idx{i,j}); 
    end
    fprintf(fid,'%s\n',idx{i,end}); 
end
fclose(fid); 

top_hits = (sum(indicator_idx >= 3,2) > floor(0.6*nsamples)) ; 
mkgrp(fullfile(otherwkdir,'hits.indels'),uniq_genes(top_hits)); 
