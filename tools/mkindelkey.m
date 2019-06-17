function [key,ix,genes,events] = mkindelkey(fname,legacy)
% MKINDELKEY  Will create a unique feature key set
%   key = MKINDELKEY(fname) will create a unique feature key given a properly
%   formatted indel table, created by gatk_format_table . The key can then be
%   used to look at commonalities across samples
% 
% see also gatk_format_table
% 
% Author: Brian Geier, BGC 2011

if nargin == 1
    legacy = 0; 
end

if ~legacy
    fid = fopen(fname); 

    c = textscan(fid,repmat('%s',[1,16]),'Delimiter','\t','Headerlines',1); 

    fclose(fid);

    snpdb = c{15}; 
    g1000db = c{16}; 
    events = c{12}; 
    genes =c{13}; 
    
    keep = strcmp('',snpdb) & strcmp('',g1000db) & ...
        ~strcmp('intronic',events) & ~strcmp('intergenic',events) & ...
        ~strcmp('nonframeshift deletion',events) & ... 
        ~strcmp('nonframeshift insertion',events) & ...
        ~strcmp('upstream;downstream',events) & ... 
        ~strcmp('upstream',events) & ... 
        ~strcmp('downstream',events) ; 
    
    key = [char(c{1}),char(c{2}),char(c{3}),char(c{4}),char(c{5})];
    key = strrep(cellstr(key),' ','');
    key = key(keep);
    ix = find(keep); 
    genes = genes(keep); 
    events = events(keep); 
    
    
else

    fid = fopen(fname); 

    c = textscan(fid,repmat('%s',[1,16]),'Delimiter','\t','Headerlines',1); 

    fclose(fid);
    
    events = c{12}; 

    keep = strcmp('',c{15}) & strcmp('',c{16}) & ...
        ~strcmp('intronic',events) & ~strcmp('intergenic',events)& ...
        ~strcmp('nonframeshift deletion',events) & ... 
        ~strcmp('nonframeshift insertion',events) & ...
        ~strcmp('upstream;downstream',events) & ... 
        ~strcmp('upstream',events) & ... 
        ~strcmp('downstream',events) ; 
    key = [char(c{1}),char(c{2}),char(c{3}),char(c{4}),char(c{5})];
    key = strrep(cellstr(key),' ','');
    key = key(keep);
    ix = find(keep); 
    genes = c{13}; 
    genes = genes(keep); 
    events = events(keep); 
    
end