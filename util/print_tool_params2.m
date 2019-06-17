
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT
function print_tool_params2(toolName, fid, s)

if isstruct(s)
    fprintf (fid, '%s: Parameters\n', toolName);
    pnames = fieldnames(s);
    for ii=1:length(pnames)
        fprintf (fid, '%s: %s\n',pnames{ii}, stringify(s.(pnames{ii})));
    end
end

% function s = stringify(x)
%     if isnumeric(x) || islogical(x)
%         s=sprintf('%g',x);
%     elseif isstruct(x)
%         s=sprintf('[%dx%d struct] fields:%s',size(x), print_dlm_line2(fieldnames(x),'-dlm',','));
%     else
%         s=sprintf('%s',x);
%     end
%     

