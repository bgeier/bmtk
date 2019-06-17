% PRINT_DLM_LINE Print a delimited line 
% PRINT_DLM_LINE(LI) prints the string cell array LI to as a tab-delimited string to STDOUT
% PRINT_DLM_LINE(LI,FID) prints the line to file handle FID
% PRINT_DLM_LINE(LI,FID,SEP) uses SEP as the delimited
% L = PRINT_DLM_LINE(LI) returns a char array of the delimited line.

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function varargout = print_dlm_line(li,fid,dlm,varargin)

pnames = {'-dlm','-precision'};
dflts = {'\t', 4};
arg = getargs2(pnames, dflts, varargin{:});
numfmt = sprintf('%%.%df', arg.precision);
nout=nargout;
printline=1;

if isequal(nout,1)
    printline=0;    
elseif ~exist('fid','var')
    fid=1;
end


if ~exist('dlm','var')
    fmt = ['%s','\t'];
else
    fmt = ['%s',dlm];
end
    
nl=length(li);
s='';
for ii=1:nl
    if isnumeric(li{ii}) || islogical(li{ii})
        li{ii} = num2str(li{ii}, numfmt);
    end
    
    if ~isequal(ii,nl)
        s = [s, sprintf(fmt,li{ii})];
    elseif printline
        s = [s, sprintf('%s\n',li{ii})];
    else
        s = [s, sprintf('%s',li{ii})];
    end

end

if ~printline 
    varargout(1) ={s};
else
    fprintf (fid,'%s',s);
end
