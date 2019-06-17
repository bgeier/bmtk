function table = hiseq_format_table(varargin)
% HISEQ_FORMAT_TABLE    Adjust annotation table columns
%   table = hiseq_format_table(varargin) will read annotated snp output
%   from hiseq_annotate and will give a single column for segmental
%   duplication, snp131, and 1000 genome project. 
%   Inputs: 
%       '-snp_table': fname
%       '-out': The output directory, file will be saved to this location
%   Outputs: 
%       A formated snp annotation file
% 
% see also hiseq_annotate
% 
% Author: Brian Geier, BGC 2011

toolName = mfilename ; 
pnames = {'-snp_table','-out'};
dflts = {'',pwd}; 

arg = getargs2(pnames,dflts,varargin{:});

print_tool_params2(toolName,1,arg); 

fid = fopen(arg.snp_table);
table.data = textscan(fid,repmat('%s',[1,15]),'Delimiter','\t');
fclose(fid);

otherwkdir = mkworkfolder(arg.out,toolName); 

table.chr = table.data{1};
table.start = table.data{2} ;
table.end = table.data{3}; 
table.ref = table.data{4}; 
table.obs = table.data{5}; 
table.allele = table.data{6} ;
% field 7 is blank
table.events = table.data{8} ; 
table.nearest_gene = table.data{9}; 
table.db1 = table.data{11};
table.db1(~strcmp('segdup',table.data{10}))={''}; % segdups are always first
col1 = table.data{11}; col2 = table.data{13}; col3 = table.data{15}; 

table.db2 = cell(size(table.db1));
table.db2(strcmp('snp131',table.data{10})) = col1(strcmp('snp131',table.data{10}));
table.db2(strcmp('snp131',table.data{12})) = col2(strcmp('snp131',table.data{12}));
table.db2(strcmp('snp131',table.data{14})) = col3(strcmp('snp131',table.data{14}));

table.db3 = cell(size(table.db1));
table.db3(strcmp('vcf',table.data{10})) = col1(strcmp('vcf',table.data{10}));
table.db3(strcmp('vcf',table.data{12})) = col2(strcmp('vcf',table.data{12}));
table.db3(strcmp('vcf',table.data{14})) = col3(strcmp('vcf',table.data{14}));

db1_val = table.db1; db2_val = table.db2; db3_val = table.db3;

table.data = [];

dbs = {'segdup','snp131','vcf'};
fid = fopen(fullfile(arg.out,[pullname(arg.snp_table),'_formatted_header.txt']),'w');
fprintf(fid,repmat('%s\t',[1,11]),'Chromosome','Start','End','Ref',...
    'Obs','Allele','Event','Nearest Gene',dbs{1},dbs{2},dbs{3});
fprintf(fid,'\n'); 
fclose(fid); 


num_lines = length(table.chr); num_blocks = 80; 
start_stops = populate_indices(num_lines,num_blocks); 
start_stops(1,:) = start_stops(1,:) + 1; 
start_stops(2,:) = cumsum(start_stops(2,:)); 

parfor k = 1 : num_blocks
    fid = fopen(fullfile(otherwkdir,[pullname(arg.snp_table),...
        '_formatted_',num2str(k),'.txt']),'w');
    for i = colon(start_stops(1,k),start_stops(2,k))
        fprintf(fid,repmat('%s\t',[1,8]),table.chr{i},table.start{i},...
            table.end{i},table.ref{i},table.obs{i},table.allele{i},...
            table.events{i},table.nearest_gene{i});
        fprintf(fid,'%s\t%s\t%s\n',db1_val{i},db2_val{i},db3_val{i}); 
    end
    fclose(fid); 
end

system(['cat ',fullfile(otherwkdir,'*'),' > ',fullfile(arg.out,...
    [pullname(arg.snp_table),'_formatted.txt'])]);
rm(otherwkdir); 

system(['cat ',...
    fullfile(arg.out,[pullname(arg.snp_table),'_formatted_header.txt']),...
    ' ',fullfile(arg.out,...
    [pullname(arg.snp_table),'_formatted.txt']),' > ',fullfile(arg.out,...
    [pullname(arg.snp_table),'_snp_table.txt'])]); 
system(['rm ',fullfile(arg.out,[pullname(arg.snp_table),'_formatted_header.txt']),...
    ' ',fullfile(arg.out,...
    [pullname(arg.snp_table),'_formatted.txt'])]); 

end

function start_stops = populate_indices(num_lines,num_blocks)

block_size = floor(num_lines/num_blocks); 
% skip m lines, then read n lines
start_stops = zeros(2,num_blocks); 

reps=[0,1:(num_blocks-1)];
start_stops(1,:) = reps.*(block_size); % skip m lines
start_stops(2,:) = block_size ; % read block of n lines
start_stops(2,end) = num_lines - start_stops(1,end) ; 

end