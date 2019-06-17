% MKGCT.M Create a gct file
%   MKGCT(OFILE, GE, GN, GD, SID) Creates OFILE in gct format using the
%   data matrix GE, row names GN, row descriptions GD and column names SID.
%
%   MKGCT(OFILE, GE, GN, GD, SID, PRECISION) restricts number of figures
%   after the decimal point to PRECISION digits. PRECISION is an integer >=
%   0.
% See also parse_gct

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function mkgct(ofile, ge,gn,gd,sid,precision, appenddim)

[nr,nc] = size(ge);

if exist('appenddim', 'var')
    if appenddim
        [p, f, e] = fileparts(ofile);
        ofile = fullfile(p, sprintf('%s_n%dx%d.gct', f, nc, nr));
    end
end

fprintf('Saving file to %s\n', ofile')
fprintf ('Dimensions of matrix: [%dx%d]\n', nr, nc)

if (~exist('precision','var'))  
    fmt = '%f\t';
else
    precision=round(precision);
    fprintf ('Setting precision to %d\n',precision);
    fmt = sprintf('%%.%df\t',precision');
end

fid = fopen(ofile,'wt');

fprintf(fid,'#1.2\n%d\t%d\n',nr,nc);

print_dlm_line(['Name';'Description';sid(:)], fid);

for ii=1:nr
    s = sprintf (fmt, ge(ii,:));
    fprintf (fid, '%s\t%s\t%s\n',gn{ii},gd{ii},s(1:end-1));    
end
fclose(fid);
fprintf ('Saved.\n')
