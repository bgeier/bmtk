function otherwkdir = pool_vcf(varargin)

toolName = mfilename ; 
pnames = {'-vcf','-out','-type'};
dflts = {pwd,pwd,'snp'}; 

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 


chrs = cell(1,24) ;
for i = 1 : 22
    chrs{i} = ['chr',num2str(i)]; 
end
chrs{end-1} = 'chrX'; chrs{end} = 'chrY'; 

switch arg.type
    case 'both'
        
        for i = 2 : 24
            system(['grep -v "##" ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.variants.vcf']),...
                ' > ',fullfile(arg.vcf,'vcf',[chrs{i},'.snpstmp.vcf'])]); 
            system(['mv ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.snpstmp.vcf']),' ',...
                fullfile(arg.vcf,'vcf',[chrs{i},'.variants.vcf'])]); 
            system(['grep -v "#" ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.variants.vcf']),...
                ' | grep -v "LowQual" > ',...
                fullfile(arg.vcf,'vcf',[chrs{i},'.snpstmp.vcf'])]); 
            system(['mv ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.snpstmp.vcf']),' ',...
                fullfile(arg.vcf,'vcf',[chrs{i},'.variants.vcf'])]); 
        end
        
        system(['grep -v "LowQual" ',...
            fullfile(arg.vcf,'vcf','chr1.variants.vcf'),' > ',...
            fullfile(arg.vcf,'vcf','chr1.snpstmp.vcf')]); 
        system(['rm ',fullfile(arg.vcf,'vcf','chr1.variants.vcf')]);
        system(['mv ',fullfile(arg.vcf,'vcf','chr1.snpstmp.vcf'),...
            ' ',fullfile(arg.vcf,'vcf','chr1.variants.vcf')]);

        cmd = 'cat '; 
        for i = 1 : 24
            cmd = [cmd , ' ', fullfile(arg.vcf,'vcf',[chrs{i},'.variants.vcf'])]; 
        end

        system([cmd,' > ',fullfile(arg.out,'all.variants.vcf')]);
        
    case 'snp'

        for i = 2 : 24
            system(['grep -v "##" ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.snps.vcf']),...
                ' > ',fullfile(arg.vcf,'vcf',[chrs{i},'.snpstmp.vcf'])]); 
            system(['mv ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.snpstmp.vcf']),' ',...
                fullfile(arg.vcf,'vcf',[chrs{i},'.snps.vcf'])]); 
            system(['grep -v "#" ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.snps.vcf']),...
                ' | grep -v "LowQual" > ',...
                fullfile(arg.vcf,'vcf',[chrs{i},'.snpstmp.vcf'])]); 
            system(['mv ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.snpstmp.vcf']),' ',...
                fullfile(arg.vcf,'vcf',[chrs{i},'.snps.vcf'])]); 
        end
        
        system(['grep -v "LowQual" ',...
            fullfile(arg.vcf,'vcf','chr1.snps.vcf'),' > ',...
            fullfile(arg.vcf,'vcf','chr1.snpstmp.vcf')]); 
        system(['rm ',fullfile(arg.vcf,'vcf','chr1.snps.vcf')]);
        system(['mv ',fullfile(arg.vcf,'vcf','chr1.snpstmp.vcf'),...
            ' ',fullfile(arg.vcf,'vcf','chr1.snps.vcf')]);

        cmd = 'cat '; 
        for i = 1 : 24
            cmd = [cmd , ' ', fullfile(arg.vcf,'vcf',[chrs{i},'.snps.vcf'])]; 
        end

        system([cmd,' > ',fullfile(arg.out,'all.snps.vcf')]); 
        
    case 'indel'
        
        for i = 2 : 24
            system(['grep -v "##" ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.indels.vcf']),...
                ' > ',fullfile(arg.vcf,'vcf',[chrs{i},'.indelstmp.vcf'])]); 
            system(['mv ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.indelstmp.vcf']),' ',...
                fullfile(arg.vcf,'vcf',[chrs{i},'.indels.vcf'])]); 
            system(['grep -v "#" ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.indels.vcf']),...
                ' > ',fullfile(arg.vcf,'vcf',[chrs{i},'.indelstmp.vcf'])]); 
            system(['mv ',fullfile(arg.vcf,'vcf',...
                [chrs{i},'.indelstmp.vcf']),' ',...
                fullfile(arg.vcf,'vcf',[chrs{i},'.indels.vcf'])]); 
        end

        cmd = 'cat '; 
        for i = 1 : 24
            cmd = [cmd , ' ', ...
                fullfile(arg.vcf,'vcf',[chrs{i},'.indels.vcf'])]; 
        end

        system([cmd,' > ',fullfile(arg.out,'all.indels.vcf')]); 
        
    otherwise
        
        print_str('Wrong type, only indel or snp')
        
end
        