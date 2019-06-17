
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function lx = safe_log(x, minval)
if ~exist('minval','var')
    minval = 1;
end
lx = log(max(x,minval));
