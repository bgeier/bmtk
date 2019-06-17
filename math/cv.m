% CV Compute coefficient of variation.
%
% CVAR = CV(M) Compute the coefficient of variation (CVAR) of an input
% matrix M. Zero mean rows are returned as NaNs. CVAR is computed as:
% cvar = std(m,0,2)./mean(m,2);

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT

function cvar = cv(m)

if length(m) < 5 || isempty(m)
    cvar = NaN; 
else
    cvar = nanstd(m,0,2)./nanmean(m,2);
end

