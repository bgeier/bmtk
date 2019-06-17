% ISFILEEXIST Checks if file(s) or folder(s) exist.
%   IE = ISFILEEXIST(FN) Checks for files or directories named FN. FN can
%   be a chararcter string or a character cell array. IE is logical true
%   (1) if the file(s) exist.
%
%   IE = ISFILEEXIST(FN, 'file') checks for files and directories.
%   IE = ISFILEEXIST(FN, 'dir') check for only directories.
%   See also EXIST

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT

function ie = isfileexist(fname, ftype)

validtypes = {'file','dir','filedir'};
if exist('ftype', 'var')
    if ~isvalidstr(ftype, validtypes)
        error('Unknown type: %s', ftype)
    end
else
    ftype = 'filedir';
end
if iscell(fname)
    nf = length(fname);
    status = false(nf,1);
    for ii=1:nf
        status(ii) = isfileexist(fname{ii}, ftype);
        if ~status(ii)
            fprintf ('"%s" not found\n', fname{ii});
        else
            fprintf ('"%s" found\n', fname{ii});
        end
    end
    ie = all(status);
else    
    % file or dir (default)
    ie = exist(fname, 'file')>0;
    switch ftype                    
        case 'file'
            ie = ie & ~isdir(fname);
        case 'dir'
            ie = ie & isdir(fname);
    end
    
end
