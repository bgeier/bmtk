
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT
function xm = do_xform(m,xform,valid_xform,verbose)

xm=[];
if ~exist('verbose','var')
    verbose=false;
end

if ~exist('valid_xform','var')
    valid_xform={'abs','log2','log','pow2','exp','zscore','none'};
end

%check if valid zform
xform=lower(xform);
if isempty (strmatch(xform, valid_xform))
    error ('Invalid transform specified: %s\n',xform);
end

if verbose
    fprintf ('Performing transformation: %s\n',xform);
end

switch(xform)
    case 'abs'
        xm=abs(m);
    case 'log2'
        xm=safe_log2(m);
    case 'log'
        xm=safe_log(m);
    case 'pow2'        
        xm=pow2(m);
    case 'exp'
        xm=exp(m);
    case 'zscore'
        xm=zscore(m);
    case 'none'
        xm=m;
end
