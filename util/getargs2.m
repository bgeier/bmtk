function [s,eid,emsg,matchidx,varargout]=getargs2(pnames,dflts,varargin)
% GETARGS Process parameter name/value pairs for functions 
%   ARG = GETARGS(PNAMES, DFLTS, 'NAME1',VAL1,'NAME2',VAL2,...)
%   accepts a cell array PNAMES of valid parameter names, a cell array
%   DFLTS of default values for the parameters named in PNAMES, and
%   additional parameter name/value pairs.  Returns parameter values in a
%   structure ARG with fields NAME1, NAME2,...
%   Example:
%       pnames = {'color' 'linestyle', 'linewidth'}
%       dflts  = {    'r'         '_'          '1'}
%       x = {'linew' 2 'nonesuch' [1 2 3] 'linestyle' ':'}
%       arg = getargs(pnames,dflts,x{:})
% Ignores leading dases in the parameter names. For example '-color' or
% '--color' would also work.

emsg = '';
eid = '';
nparams = length(pnames);
varargout = dflts;
unrecog = {};
nargs = length(varargin);
varnames = regexprep(pnames, '^-+', '');
s=cell2struct(dflts,varnames,2);
matchidx=zeros(nparams,1);
% turn off debugging
warning('on', 'GETARGS:paramUnrecognized');

if any(strcmp('-help', varargin))
    stk = dbstack;
    callers = {stk.file};
    help (callers{2})
    error('Bad Arguments');
end

% Must have name/value pairs
if mod(nargs,2)~=0
    eid = 'WrongNumberArgs';
    emsg = 'Wrong number of arguments.';
else
    % Process name/value pairs
    for j=1:2:nargs
        pname = regexprep(varargin{j},'^-+','');
        if ~ischar(pname)
            eid = 'BadParamName';
            emsg = 'Parameter name must be text.';
            break;
        end
        %i = strmatch(lower(pname),pnames,'exact');        
        i = find(strcmpi(pname, varnames));
        if isempty(i)
            % if they've asked to get back unrecognized names/values, add this
            % one to the list
            if nargout > nparams+2
                unrecog((end+1):(end+2)) = {varargin{j} varargin{j+1}};                                
            else
                warning('GETARGS:paramUnrecognized', 'Skipping unrecognized parameter: %s', pname);                
            end
        elseif length(i)>1
            eid = 'BadParamName';
            emsg = sprintf('Ambiguous parameter name:  %s.',pname);
            break;
        else
            varargout{i} = varargin{j+1};
            matchidx(i)=j+1;            
            s.(varnames{i}) = assign_val(mystringify(varargin{j+1}), dflts{i});
        end
    end
end

varargout{nparams+1} = unrecog;


function res = assign_val(val, cls)
switch class(cls)    
    case {'char'}
        res = val;
        if isempty(res)
           res = '';
        end
    case {'double','single', 'int8' ,'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64','uint64'}
        res = str2double(val);
    case {'logical'}
        res = logical(str2num(val));
    otherwise
        res = val;
end

% Convert input to string
% a modified version of stringify.m to handle structs correctly and avoid
% recursion problems.
function s = mystringify(x)

if isempty(x)
    s = '';
else
    [r,c] = size(x);
    if r==1
        if isnumeric(x) || islogical(x)
            s=sprintf('%g', x);
        elseif ischar(x)
            s=sprintf('%s',x);
        elseif isstruct(x)
            s = x;
            % catch all, could be dangerous
        else
            s = x;
        end        
    elseif r>1        
        s=cell(r,1);
        if isnumeric(x) || islogical(x)
            s = strtrim(num2cellstr(x, '-fmt', '%g'));            
        elseif iscellstr(x)
            s=x;
        end        
    end
end