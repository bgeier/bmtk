% NUM2CELLSTR Convert an array of numbers into a cell array of strings
%   C = NUM2CELLSTR(X) 
%

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function c = num2cellstr(x,varargin)

[nr, nc] = size(x);
pnames = {'-fmt', '-precision'};
dflts = {'%g', nan};
arg = getargs2(pnames, dflts, varargin{:});
if ~isnan(arg.precision)
    arg.fmt = sprintf('%%.%df', arg.precision);
end

if ~isempty(x)
    c = reshape(strtrim(cellstr(num2str(x(:),arg.fmt)).'),nr,nc);
else
    c = '';
end

