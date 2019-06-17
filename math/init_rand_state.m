
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT
function s = init_rand_state(method)

valid_method={'twister','state','seed'};
default_state='twister';

if ~exist('method','var')
    method = default_state;
end

if ~strmatch(lower(method), valid_method)
    error('Unknown rand generator: %s',method);
end

rand(method,sum(100*clock));
s=rand(method);
