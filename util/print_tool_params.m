
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT
function print_tool_params(toolName, pnames, fid, varargin)

if isequal(length(varargin), length(pnames))
    fprintf (fid, '%s: Parameters\n', toolName);
    for ii=1:length(pnames)
        fprintf (fid, '%s: %s\n',pnames{ii}, stringify(varargin{ii}));
    end
end


function s = stringify(x)
    if isnumeric(x) || islogical(x)
        s=sprintf('%g',x);
        
    else
        s=sprintf('%s',x);
    end
    

