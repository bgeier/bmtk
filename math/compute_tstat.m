function tstat = compute_tstat(x,y)
% COMPUTE_TSTAT     Compute Two Sample T-Statistic Assuming Unequal Var

seg1 = var(x);
seg2 = var(y); 
ngrp1 = length(x); ngrp2 = length(y); 
grpmean_diff = mean(x)-mean(y);
df = ngrp1 + ngrp2 - 2;
pooled_se = sqrt(((ngrp1-1) .* seg1 + (ngrp2-1) .* seg2) ./ df);
grpse = pooled_se .* sqrt(1./ngrp1 + 1./ngrp2);
tstat = double(grpmean_diff ./ grpse);