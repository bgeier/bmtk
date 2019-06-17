function mkconfig_indels_intervals(varargin)
% pnames = {'-gatk_path','-bam','-reference','-out','-snp_vcf','-indel_vcf',...
%     '-java_path','-dbsnp'};
% dflts = {'/illumina/applications/GenomeAnalysisTK-1.0.5083','','',pwd,...
%     '','','',''}; 

toolName = mfilename ; 
pnames = {'-gatk_path','-bam','-reference','-out','-snp_vcf','-indel_vcf',...
    '-java_path','-dbsnp'};
dflts = {'/illumina/applications/gatk/dist','','',pwd,...
    '','','',''}; 

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 

mkdir(otherwkdir,'sh'); 
mkdir(otherwkdir,'targets'); 
mkdir(otherwkdir,'logs'); 
chrs = cell(1,24) ;
for i = 1 : 22
    chrs{i} = ['chr',num2str(i)]; 
end
chrs{end-1} = 'chrX'; chrs{end} = 'chrY'; 

header = {'#!/bin/sh',...
    '#$ -cwd',...
    '#$ -S /bin/sh',...
    '#$ -j y',...
    'set -x'};

for i = 1 : length(chrs)
    fid = fopen(fullfile(otherwkdir,'sh',[chrs{i},'.indels_intervals']),'w'); 
    for j = 1 : length(header)
        fprintf(fid,'%s\n',header{j}); 
    end
    fprintf(fid,'%s\n',['time ',fullfile(arg.java_path,'java'),' ',...
        ' -jar ',fullfile(arg.gatk_path,...
        'GenomeAnalysisTK.jar'),' -T RealignerTargetCreator -R ',...
        arg.reference,' -o ',fullfile(otherwkdir,'targets',...
        [chrs{i},'.intervals']),' -I ',arg.bam, ' -L ',chrs{i},...
        ' -B:dbsnp,VCF ',arg.dbsnp,...
        ' -B:snps,VCF ',arg.snp_vcf,...
        ' -B:indels,VCF ',arg.indel_vcf]); 
    fclose(fid);
end
 
% fid = fopen(fullfile(otherwkdir,'sh','driver.sh'),'w'); 
% fprintf(fid,'%s\n\n','#!/bin/bash'); 
% for i = 1 : length(chrs)
%     fprintf(fid,'%s\n',['qsub ',chrs{i},'.indels_intervals ;']); 
% end
% fclose(fid); 
% 
% system(['chmod 755 ',fullfile(otherwkdir,'sh','driver.sh')]); 

fid = fopen(fullfile(otherwkdir,'targets','sort_intervals.sh'),'w'); 
fprintf(fid,'%s\n\n','#!/bin/bash');
cmd = 'cat '; 
for i = 1 : length(chrs)
    cmd = [cmd, ' ' ,chrs{i},'.intervals'];  
end
cmd = [cmd, ' > ',fullfile(otherwkdir,'sorted.intervals')]; 
fprintf(fid,'%s\n',cmd); 
fclose(fid); 

system(['chmod 755 ',fullfile(otherwkdir,'targets','sort_intervals.sh')]); 