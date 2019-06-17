function mkconfig_DepthOfCoverage(varargin)
% pnames = {'-gatk_path','-bam','-reference','-out','-mmq','-mbq'};
% dflts = {'/illumina/applications/GenomeAnalysisTK-1.0.5083','','',pwd,20,17}; 

toolName = mfilename ; 
pnames = {'-gatk_path','-bam','-reference','-out','-mmq','-mbq'};
dflts = {'/illumina/applications/GenomeAnalysisTK-1.0.5083','','',pwd,20,17}; 

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 

mkdir(otherwkdir,'depth'); 
mkdir(otherwkdir,'sh');

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
    fid = fopen(fullfile(otherwkdir,'sh',[chrs{i},'.DepthOfCoverage']),'w'); 
    for j = 1 : length(header)
        fprintf(fid,'%s\n',header{j}); 
    end
    fprintf(fid,'%s\n',['time /illumina/applications/jre1.6.0_24/bin/java',...
        ' -jar ',fullfile(arg.gatk_path,...
        'GenomeAnalysisTK.jar'),' -T DepthOfCoverage -R ',...
        arg.reference,' -o ',fullfile(otherwkdir,'depth',...
        [chrs{i},'.depth']),' -I ',arg.bam, ' -L ',...
        chrs{i},' -mmq ',num2str(arg.mmq),' -mbq ',num2str(arg.mbq),' --printBaseCounts ',...
        '--omitLocusTable -omitSampleSummary --includeDeletions']); 
    fclose(fid); 
end

fid = fopen(fullfile(otherwkdir,'sh','driver.sh'),'w'); 
fprintf(fid,'%s\n\n','#!/bin/bash'); 
for i = 1 : length(chrs)
    fprintf(fid,'%s\n',['qsub ',chrs{i},'.DepthOfCoverage ;']); 
end
fclose(fid); 
system(['chmod 755 ',fullfile(otherwkdir,'sh','driver.sh')]); 