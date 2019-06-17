% PARSE_GRP Read GRP files
%   L = PARSE_GRP(FNAME) Reads a GRP format file. 
%
%   Format Details:
%   The GRP files contain a list in a simple newline-delimited
%   text format. Lines that start with a # are ignored.

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function l = parse_grp(fname)

l = textread(fname, '%s', 'delimiter','\n', 'commentstyle','shell');

