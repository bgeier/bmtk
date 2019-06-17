% STRINGIFY Convert input to string
% allowed inputs char, numeric, logical

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT
function s = stringify(x, varargin)

pnames = {'-fmt','-struct2str'};
dflts = {'%g', true};
arg = getargs2(pnames, dflts, varargin{:});
%get variable name
vname = @(x) inputname(1);

if isempty(x)
    s = '';
else
    [r,c] = size(x);
    if r==1
        
        if isnumeric(x) || islogical(x)
            s=sprintf(arg.fmt, x);
        elseif ischar(x)
            s=sprintf('%s',x);
        elseif isstruct(x)
            % struct dimensions as a string
            if arg.struct2str
                s = sprintf('[%dx%d struct] fields:%s',size(x), print_dlm_line2(fieldnames(x),'-dlm',','));
            else
                s = x;
            end
            % catch all, could be dangerous
        else
            s = x;
        end
        
    elseif r>1
        
        s=cell(r,1);
        if isnumeric(x) || islogical(x)
            s = strtrim(num2cellstr(x, '-fmt', arg.fmt));
            
        elseif iscellstr(x)
            s=x;
        end
        
    end
end