function vf_struct = parse_vf(fname)
% Parser for *.variant_function  ANNOVAR parser
% Author: Brian Geier, 2011


vf_struct = struct('coding_portion','','gene_symbol','',...
    'chromosome','','start_position','','end_position','','reference','',...
    'observed','','snv_type',''); 

% isParallel = spopen ; 

% if isParallel
%     num_blocks = 4*10 ; 
%     [~,num_lines] = system(['wc -l ',fname]); 
%     ix = regexp(num_lines,' '); 
%     num_lines = str2double(num_lines(ix(1)+1:ix(2)-1)) ; %% change this
%     start_stops = populate_indices(num_lines,num_blocks); 
%     tmp = cell(1,num_blocks); 
%     parfor i = 1 : num_blocks
%         fid = fopen(fname) ;
%         tmp{i} = textscan(fid,repmat('%s',[1,8]),start_stops(2,i),...
%             'Delimiter','\t','Headerlines',start_stops(1,i)); 
%         fclose(fid); 
%     end
%     
% else
    
    fid = fopen(fname,'r'); 
    c = textscan(fid,repmat('%s',[1,8]),'Delimiter','\t'); 
    fclose(fid); 
    
% end

vf_struct.coding_portion = char(c{1}); c{1} = [];
vf_struct.gene_symbol =  char(c{2}); c{2} = [];
vf_struct.chromosome = char(c{3}); c{3} = [];
vf_struct.start_position= single(str2double_parallel(c{4})); c{4} = [];
vf_struct.end_position= single(str2double_parallel(c{5})); c{5} = [];
vf_struct.reference= char(c{6}); c{6} = [];
vf_struct.observed= char(c{7}); c{7} = [];
vf_struct.snv_type= char(c{8}); c{8} = [];
    
clear c ; 

end

% function c = unzip_blocks(blocks) 
% % concatenate input blocks
% 
% num_fields = 8  ;
% 
% 
% end
% 
% function start_stops = populate_indices(num_lines,num_blocks)
% 
% block_size = floor(num_lines/num_blocks); 
% % skip m lines, then read n lines
% start_stops = zeros(2,num_blocks); 
% 
% reps=[0,1:(num_blocks-1)];
% start_stops(1,:) = reps.*(block_size); % skip m lines
% start_stops(2,:) = block_size ; % read block of n lines
% start_stops(2,end) = num_lines - start_stops(1,end) ; 
% 
% end