
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT
function isvalid = isvalidstr(s, vs)
if iscell(s)
    ns = length(s);
    isvalid = false(ns, 1);
    for ii=1:ns
        isvalid(ii) = chk(s{ii}, vs);
    end
elseif ischar(s)
    isvalid = chk(s, vs);
end

end

function isvalid = chk(s, vs)
    isvalid = ~isempty (strmatch(s, vs));
end
