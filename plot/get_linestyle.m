
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT
function st = get_linestyle(n, varargin)

pnames = {'-attr'};
dflts = {'col,sym,dash'};
arg=getargs2(pnames, dflts, varargin{:});
vs = {'col','sym','dash'};
attr = unique(tokenize(arg.attr, ',', true));
if ~all(isvalidstr(attr, vs))
    error('Invalid attribute str %d. [Valid options: col,sym,dash]', arg.attr);
end
usecol = isvalidstr(vs{1}, attr);
usesymb = isvalidstr(vs{2}, attr);
usedash = isvalidstr(vs{3}, attr);

col='rgbck';
symb = 'oxs*^dv.';
dash = {'-','--',':','-.'};
ncol = usecol*(length(col));
nsymb = usesymb*length(symb);
ndash = usedash*length(dash);

nc = min(n, ncol);

if nc>0
    ns = min(ceil(n/nc), nsymb);
    if ns>0
        nd = min(ceil(n/(nc*ns)), ndash);
    else
        nd = min(n, ndash);
    end
else
    ns = min(n, nsymb);
    if ns>0
        nd = min(ceil(n/ns), ndash);
    else
        nd = min(n, ndash);
    end
end


st = cell(n,1);
is=min(1,ns);
ic=min(1,nc);
id=min(1,nd);

for ii=1:n
    s='';
    if usecol
        s=col(ic);
        ic = mod(ic, nc)+1;
    end
    if usesymb
        s=[s,symb(is)];
        if (nc>0 && ic == nc)
            is = mod(is, ns)+1;
        elseif nc==0
            is = mod(is, ns)+1;
        end
    end
    if usedash
        s=[s,dash{id}];
        if (ns>0 && is == ns) || (nc>0 && ic == nc)
            id = mod(id, nd)+1;
        elseif ns==0 && nc==0
            id = mod(id, nd)+1;
        end
    end
    
    st{ii} = s;
end


end
