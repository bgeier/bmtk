%PARSE_GMT Read .gmt Gene matrix transposed data format
% GMT = PARSE_GMT(FNAME) Reads .gmt file FNAME and returns the structure
% GMT. GMT is a nested structure GMT(1...NCOLS), where NCOLS is the number
% of rows in the GMT file. Each structure has the following fields:
%   head: column header, 1st column of the .gmt file 
%   desc: column description, 2nd column of the .gmt file 
%   len: length of the geneset
%   entry: cell array of column entries
% 
% Format Details:
% The GMT file format is a tab delimited file format that describes gene 
% sets. In the GMT format, each row represents a gene set. By contrast in 
% the GMX format, each column represents a gene set. Each gene set is 
% described by a unique geneset name, a brief description, and the genes 
% in the gene set. Unequal lengths (i.e. number of genes) are allowed. 
%
% CAVEAT: this code does not handle missing values

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

% 3/6/2008, returns nested structure instead of variables

function gmt = parse_gmt(fname)
try 
    fid = fopen(fname,'rt');
catch
    rethrow(lasterror);
end


gmt = struct('head',[],'desc',[],'len',[],'entry',[]);

rec=1;
while ~feof(fid)
    l=fgetl(fid);
    f = textscan(l,'%s','delimiter','\t');
    gmt(rec).head = char(f{1}(1));
    gmt(rec).desc = char(f{1}(2));
    gmt(rec).len = length(f{1})-2;
    gmt(rec).entry = f{1}(3:end);
    rec=rec+1;
end

fclose(fid);




