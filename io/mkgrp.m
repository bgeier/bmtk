% MKGRP make a GRP format file
%   MKGRP(FNAME, LIST) Creates a grp file FNAME using a cell array of
%   strings LIST as the input
%
%   Format Details:
%   The GRP files contain a list in a simple newline-delimited
%   text format. Lines that start with a # are ignored.
%
%   See also: parse_grp

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function mkgrp(fname, li)

nargchk(2,2,nargin);

fid = fopen(fname ,'wt');
print_dlm_line(li, fid, '\n');
fclose(fid);
