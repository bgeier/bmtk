function otherwkdir = mkconfig_Indelgenotyper(varargin)
% pnames = {'-gatk_path','-bam','-reference','-out','-min_coverage','-java_path'};
% dflts = {'/illumina/applications/GenomeAnalysisTK-1.0.5083','','',pwd,6,...
%     ''};


toolName = mfilename ; 
pnames = {'-gatk_path','-bam','-reference','-out','-min_coverage','-java_path'};
dflts = {'/illumina/applications/GenomeAnalysisTK-1.0.5083','','',pwd,6,...
    '/illumina/applications/jre1.6.0_24/bin'};

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 

mkdir(otherwkdir,'sh'); 
mkdir(otherwkdir,'verbose'); 
mkdir(otherwkdir,'vcf');
mkdir(otherwkdir,'bed');

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
    fid = fopen(fullfile(otherwkdir,'sh',[chrs{i},'.indelgenotyper']),'w'); 
    for j = 1 : length(header)
        fprintf(fid,'%s\n',header{j}); 
    end
    fprintf(fid,'%s\n',['time ',fullfile(arg.java_path,'java'),...
        ' -jar ',fullfile(arg.gatk_path,...
        'GenomeAnalysisTK.jar'),' -T IndelGenotyperV2 -R ',...
        arg.reference,' -o ',fullfile(otherwkdir,'vcf',...
        [chrs{i},'.indels.vcf']),' -I ',arg.bam, ' -L ',...
        chrs{i},' -bed ',fullfile(otherwkdir,'bed',[chrs{i},'.bed']),...
        ' --minCoverage ',num2str(arg.min_coverage),...
        ' -verbose ',fullfile(otherwkdir,'verbose',[chrs{i},'details.txt'])]);
    fclose(fid); 
end

fid = fopen(fullfile(otherwkdir,'sh','driver.sh'),'w'); 
fprintf(fid,'%s\n\n','#!/bin/bash'); 
for i = 1 : length(chrs)
    fprintf(fid,'%s\n',['qsub ',chrs{i},'.indelgenotyper ;']); 
end
fclose(fid); 
system(['chmod 755 ',fullfile(otherwkdir,'sh','driver.sh')]); 