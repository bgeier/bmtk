% GEN_CALIB_MATRIX Generate expression matrix of L-1000 calibration genes
% [cm,cn,cd, sid]  = gen_calib_matrix(gmxFile, gctFile)

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT

function [cm,cn,cd, sid]  = gen_calib_matrix(gmxFile, gctFile)

% gmx struct: name, desc, len,
if isstruct(gmxFile)
    gmx=gmxFile;
elseif isfileexist(gmxFile)
    gmx = parse_gmx(gmxFile);
else
    error('gmxFile:%s notfound',gmxFile);
end

% gct struct: ge, gn, gd, sid
if isstruct(gctFile)
    ds = gctFile;
    clear gctFile;
elseif isfileexist(gctFile)
    [ds.ge, ds.gn, ds.gd, ds.sid] = parse_gct(gctFile);
else
    error('gctFile:%s notfound', gctFile);
end

nCalib = length(gmx);
nSample = size(ds.ge,2);

cm = zeros(nCalib, nSample);
cn = cell(nCalib,1);
cd = cell(nCalib,1);
sid = ds.sid;

for ii=1:nCalib
    [c,idx] = intersect_ord(ds.gn, gmx(ii).entry);
    if isempty(idx)
        error ('No calib genes found at level %d\n',ii);
    elseif ~isequal(length(idx), gmx(ii).len)
        fprintf ('Warning: Some genes not found at level %d\n',ii);
        disp(setdiff(gmx(ii).entry, c));
    end
    
    cm(ii,:)  = max(nanmedian(ds.ge(idx,:), 1), 0);
    cn{ii} = gmx(ii).head;
    cd{ii} = gmx(ii).desc;
end

