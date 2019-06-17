function [key,ix,genes,events] = mksnpkey(fname,legacy)
% MKSNPKEY  Will create a unique feature key set
%   [key,ix,genes,events] = MKSNPKEY(fname) will create a unique feature 
%   key given a properly formatted snp table, created by gatk_format_table. 
%   The key can then be used to look at commonalities across samples.
% 
% see also gatk_format_table
% 
% Author: Brian Geier, BGC 2011

if nargin == 1
    legacy = 0; 
end

if ~legacy

    fid = fopen(fname); 

    c = textscan(fid,repmat('%s',[1,17]),'Delimiter','\t','Headerlines',1); 

    fclose(fid);
    % meta = c{10};
    % allele = cell(length(meta),1);
    % 
    % parfor i = 1  : length(meta)
    %     if isempty(strfind(meta{i},'AF=0.50'))
    %         allele{i} = 'hom';
    %     else
    %         allele{i} = 'het' ;
    %     end
    % end

    allele = c{6};
    gatk_classify = c{12};
    snpdb = c{16}; 
    g1000db = c{17}; 
    events = c{13}; 
    genes =c{14}; 

%     keep = strcmp('PASS',gatk_classify) & strcmp('',snpdb) & strcmp('',g1000db) & ...
%         ~strcmp('intronic',events) & ~strcmp('intergenic',events) & ... 
%         ~strcmp('synonymous SNV',events) ; 
    g = str2double(g1000db); 
    g(isnan(g)) = 0; 
    keep = strcmp('PASS',gatk_classify) & strcmp('',snpdb) & g<0.01 & ...
        ~strcmp('intronic',events) & ~strcmp('intergenic',events) & ... 
        ~strcmp('synonymous SNV',events) ; 
    key = [char(c{1}),char(c{2}),char(c{3}),char(c{4}),char(c{5}),char(allele)];
    key = strrep(cellstr(key),' ','');
    key = key(keep); 
    ix = find(keep);
    genes = genes(keep); 
    events = events(keep); 
    
else
    
    fid = fopen(fname); 

    c = textscan(fid,repmat('%s',[1,16]),'Delimiter','\t','Headerlines',1); 

    fclose(fid);
    meta = c{10};
    allele = cell(length(meta),1);
    
    parfor i = 1  : length(meta)
        if isempty(strfind(meta{i},'AF=0.50'))
            allele{i} = 'hom';
        else
            allele{i} = 'het' ;
        end
    end

%     allele = c{6};
    gatk_classify = c{11};
    snpdb = c{15}; 
    g1000db = c{16}; 
    events = c{12}; 
    genes = c{13}; 

%     keep = strcmp('PASS',gatk_classify) & strcmp('',snpdb) & strcmp('',g1000db) & ...
%         ~strcmp('intronic',events) & ~strcmp('intergenic',events) & ... 
%         ~strcmp('synonymous SNV',events) ; 
    g = str2double(g1000db); 
    g(isnan(g)) = 0; 
    keep = strcmp('PASS',gatk_classify) & strcmp('',snpdb) & g<0.01 & ...
        ~strcmp('intronic',events) & ~strcmp('intergenic',events) & ... 
        ~strcmp('synonymous SNV',events) ; 
    key = [char(c{1}),char(c{2}),char(c{3}),char(c{4}),char(c{5}),char(allele)];
    key = strrep(cellstr(key),' ','');
    key = key(keep); 
    ix = find(keep); 
    genes = genes(keep) ;
    events = events(keep); 
end