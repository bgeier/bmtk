% CV_MEDIAN Compute coefficient of variation based on the median.
%
% CVAR = CV_MEDIAN(M) Compute the median derived analog of coefficient of 
% variation (CVAR) of an input matrix M. Zero median rows are returned as 
% NaNs. CVAR is computed as:
% cvar = std(m,0,2)./median(m,2);

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT

function cvar = cv_median(m)

cvar = std(m,0,2)./median(m,2);

