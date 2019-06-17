% MKSIN Create a sin file
% MKSIN(SIN,SINFILE) Creates a sin file given a structure (SIN) with 
% fieldnames set to header labels in row one of SINFILE.

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function mksin(sins,sinfile,varargin)

pnames = {'-precision', '-emptyval'};
dflts = {4, ''};
arg = getargs2(pnames, dflts, varargin{:});

nr = length(sins);
fn = fieldnames(sins);
nf = length(fn);
numfmt = sprintf('%%.%df', arg.precision);

if isequal (nr,1)
    %legacy mode, single structure where each fieldname is a cell array of
    % size nrec
    nrec = length(sins.(fn{1}));
    x=struct2cell(sins);
    
    isnum = cellfun(@(x) isnumeric(x)||islogical(x), x);
    if any(isnum)
        idx = find(isnum);
        n = nnz(isnum);
        for ii=1:n
           x{idx(ii)} =  num2str(x{idx(ii)}, numfmt);
        end
    end
    
    data = [x{:}];
else
    % preferred form, structure array of size nrec
    nrec = nr;
    data = struct2cell(sins(:))';
end

fprintf ('Saving file to %s [%dr x %dc]\n', sinfile, nrec, nf);
fid = fopen(sinfile,'wt');
%print header
print_dlm_line2(fn, '-fid', fid);

for ii=1:nrec
    print_dlm_line2(data(ii,1:nf), '-fid', fid, '-precision', arg.precision, '-emptyval', arg.emptyval)
end

fclose(fid);

