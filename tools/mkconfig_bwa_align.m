function mkconfig_bwa_align(varargin)
% MKCONFIG_BWA_ALIGN    Creat configuration files for BWA alignment
%   mkconfig_bwa_align(varargin) will creat configuration files for running
%   BWA alignment of paired read data. The BWA aligned file is sorted and
%   indexed post alignment. 
%   Inputs: 
%       '-bwa_path': The absolute path to bwa
%       '-fastq1': First pair of paired end reads, fastq file with PHRED
%       '-fastq2': Second pair of paired end reads, fastq file with PHRED
%       '-reference': The genome reference assembly
%       '-out': The output directory
%       '-sampleID': The sample identifier, used as RG ID within bwa
%       '-gatk_path': The absolute path to gatk
%       '-q': The PHRED score for read trimming during alignment, default=2
%       '-samtools_path': The absolute path to samtools
%       '-t': The number of cores to use, default=8
%       '-picard_path': Absolute path to picard tools
%   Outputs: 
%       A sorted and indexed bam file will be written to the output
%       directory with naming convention ['-sampleID','.sorted.bam'].
%       Scratch files used by BWA and samtools will be deleted at run-time.
% 
%   see also mkconfig_realign, mkconfig_genotyper
% 
% Author: Brian Geier, BGC June 2011

toolName = mfilename ; 
pnames = {'-bwa_path','-fastq1','-fastq2','-reference','-out',...
    '-sampleID','-gatk_path','-q','-samtools_path','-t','-picard_path'};
dflts = {'','','','',pwd,'','',2,'',8,''}; 

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 

header = {'#!/bin/sh',...
    '#$ -cwd',...
    '#$ -S /bin/sh',...
    '#$ -j y',...
    ['#$ -N ',arg.sampleID,'align'],...
    'set -x'};

fid = fopen(fullfile(arg.out,'bwa_align.txt'),'w'); 

for i = 1 : length(header)
    fprintf(fid,'%s\n',header{i}); 
end

fprintf(fid,'%s\n\n',['time ',fullfile(arg.bwa_path,'bwa'),' aln -t ',...
    num2str(arg.t),' -q ',...
    num2str(arg.q),' ',arg.reference,' ',arg.fastq1,' > ',fullfile(otherwkdir,...
    'read1.sai')]); 

fprintf(fid,'%s\n\n',['time ',fullfile(arg.bwa_path,'bwa'),' aln -t ',...
    num2str(arg.t),' -q ',...
    num2str(arg.q),' ',arg.reference,' ',arg.fastq2,' > ',fullfile(otherwkdir,...
    'read2.sai')]); 

fprintf(fid,'%s\n\n',['time ',fullfile(arg.bwa_path,'bwa'),' sampe -P -r ',...
    '"@RG\tID:',arg.sampleID,'\tSM:BGseq" ', arg.reference,' ',...
    fullfile(otherwkdir,'read1.sai'),' ',fullfile(otherwkdir,'read2.sai'),...
    ' ',arg.fastq1,' ',arg.fastq2,' > ',fullfile(otherwkdir,'aligned.sam')]);

fprintf(fid,'%s\n\n',fullfile(otherwkdir,'samtools.txt'));



fprintf(fid,'%s\n\n',['time java -Xmx150g -jar ',fullfile(arg.picard_path,...
    'MarkDuplicates.jar'),' ASSUME_SORTED=true REMOVE_DUPLICATES=false ',...
    ' INPUT=',fullfile(arg.out,[arg.sampleID,'.sorted.bam']),...
    ' OUTPUT=',fullfile(arg.out,[arg.sampleID,'.sorted.dedup.bam']),...
    ' METRICS_FILE=',arg.sampleID,'.dedup.metrics',...
    ' VALIDATION_STRINGENCY=SILENT TMP_DIR=/tmp CREATE_INDEX=true']); 

fprintf(fid,'%s\n\n',['rm -f ',fullfile(otherwkdir,'read1.sai'),...
    ' ',fullfile(otherwkdir,'read2.sai'),' ',...
    fullfile(otherwkdir,'aligned.sam'),' ',...
    fullfile(arg.out,[arg.sampleID,'.sorted.bam']),...
    fullfile(arg.out,[arg.sampleID,'.sorted.bam.bai'])]); 


fclose(fid); 

system(['chmod 755 ',fullfile(arg.out,'bwa_align.txt')]); 

fid = fopen(fullfile(otherwkdir,'samtools.txt'),'w'); 

header = {'#!/bin/sh',...
    '#$ -cwd',...
    '#$ -S /bin/sh',...
    '#$ -j y',...
    ['#$ -N ',arg.sampleID,'samtools'],...
    'set -x'};
for i = 1 : length(header)
    fprintf(fid,'%s\n',header{i}); 
end

fprintf(fid,'%s\n\n',['time ',fullfile(arg.samtools_path,'samtools'),...
    ' view -bS -o ',fullfile(arg.out,[arg.sampleID,'.bam']),...
    ' ',fullfile(otherwkdir,'aligned.sam')]); 

fprintf(fid,'%s\n\n',['time ',fullfile(arg.samtools_path,'samtools'),...
    ' sort -m 50000000000 ',fullfile(arg.out,[arg.sampleID,'.bam']),...
    ' ',fullfile(arg.out,[arg.sampleID,'.sorted'])]); 

fprintf(fid,'%s\n\n',['time ',fullfile(arg.samtools_path,'samtools'),...
    ' index ',fullfile(arg.out,[arg.sampleID,'.sorted.bam'])]); 
fclose(fid); 

system(['chmod 755 ',fullfile(otherwkdir,'samtools.txt')]); 