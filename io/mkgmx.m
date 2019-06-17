% MKGMX Create a GMX file.
%   MKGMX(FNAME, C, HD, DESC) where C is cell structure contaning cell 
%   array(s) of strings. HD and DESC are the cell arrays of strings.
%   The lenghts of HD and DESC should be equal to length(C).
%
%   Example:
%   C={{'a','b','c'}, {'x','y','z'}, {'foo','bar'}};
%   HD={'A','B','C'};
%   DESC = {'1','2','3'};
%   mkgmx('test.gmx', C,HD,DESC)

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function mkgmx(fname, c, hd, desc)

numcols = length(c);
csize = cellfun(@length, c);
maxlen = max(csize);

fid=fopen(fname,'wt');
print_dlm_line(hd, fid, '\t');
print_dlm_line(desc, fid, '\t');
for ii=1:maxlen
    for jj=1:numcols-1
        if (csize(jj) >= ii)
            fprintf (fid, '%s\t', c{jj}{ii});
        else
            fprintf (fid, '\t');
        end
    end    
    
    if (csize(numcols) >=ii)
        fprintf (fid, '%s\n', c{numcols}{ii});
    else
        fprintf (fid, '\t\n');
    end
    
end

fclose(fid)
