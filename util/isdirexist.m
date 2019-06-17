
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT
function ie = isdirexist(fname)

nargchk(1,1,nargin);
ie = isequal(exist(fname, 'dir'),7);
