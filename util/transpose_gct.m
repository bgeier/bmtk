% TRANSPOSE_GCT Tranpose data matrix and row and column headers
%   [GE, GN, GD, SID = transpose_gct(GE, GN, GD,SID)

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT
function [ge,gn,gd,sid] = transpose_gct(ge,gn,gd,sid, varargin)

pnames={'delim','merge_namedesc'};
dflts = {':', true};
arg = getargs2(pnames, dflts, varargin{:});

ge = ge';
if arg.merge_namedesc
    gngd = strcat(gn,arg.delim,gd);
else
    gngd = gn;
end
gn = sid;
gd = sid;
sid = gngd;
