% MKGMT Create a GMT file
% MKGMT (FNAME, C, HD, DESC)

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function mkgmt(fname, c, hd, desc)

numrows = length(c);

fid=fopen(fname,'wt');
for ii=1:numrows
    s = print_dlm_line(c{ii});        
    fprintf (fid, '%s\t%s\t%s\n', hd{ii}, desc{ii}, s);    
end

fclose(fid)
