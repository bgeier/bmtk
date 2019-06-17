% FILTER_TABLE
% filttbl = filter_table(tbl, fn, mask)
%

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT

%TODO
% input validation
% masking options
function [filttbl, keepidx] = filter_table(tbl, fn, mask)

if isstruct(tbl)
    if length(tbl)>1
        islegacy = 0;
    else
        islegacy = 1;
    end
elseif isfileexist(tbl)
    tblfile = tbl;
    tbl = parse_sin(tbl, false, '-version', 'v2');
else
    error('File not found: %s', tbl);
end

nrec = length(tbl);

keep = true(nrec, 1);
nfilt = length(fn);

for ii=1:nfilt
        if islegacy
            keep = keep & (cellfun(@length, regexp(tbl.(fn{ii}), mask{ii}))>0)';
        else
            keep = keep & (cellfun(@length, regexp({tbl.(fn{ii})}, mask{ii}))>0)';
        end
end
keepidx = find(keep);
if islegacy
    f = fieldnames(tbl);
    filttbl=([]);
    for ii=1:length(f)
        filttbl.(f{ii}) = tbl.(f{ii})(keep);
    end
else
    filttbl = tbl(keep);
end
