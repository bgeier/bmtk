% SAFE_LOG2 Compute log2 ignoring negative and zero values.
% LX = SAFE_LOG2(X) Returns log2 of X if X>1 or zero otherwise.
% LX = SAFE_LOG2(X, MINVAL) Returns log2 of X if X>MINVAL or log2(MINVAL) otherwise.
% Example
% safe_log2([0,-1,2,3,4])
% safe_log2([0,-1,2,3,4], 1)

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function lx = safe_log2(x, minval)
if ~exist('minval','var')
    minval = 1;
end
lx = log2(max(x,minval));
