% PARSE_SIN Parse a sin file
%   SIN = PARSE_SIN(SINFILE) Returns a sructure (SIN) with fieldnames set 
%   to header labels in row one of SINFILE.
%
%   SIN = PARSE_SIN(SINFILE, NOCHECK) Specifies if syntax checking is done
%   on the sin file. NOCHECK is true by default.
%
%   SIN = PARSE_SIN(SINFILE, NOCHECK, HASHEAD) Specifies if file has a
%   header row. HASHEAD is true by default.

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT


function sins = parse_sin(sinfile, nocheck, varargin)

pnames = {'-version','-numhead'};
dflts = {'legacy',1};
arg = getargs2(pnames, dflts, varargin{:});

if (exist('nocheck','var'))
    docheck = nocheck;
else
    docheck = 1;
end

% guess number of fields
% if the fieldnames have no spaces this should work

first = textread(sinfile,'%s',1,'delimiter','\n','headerlines',max(arg.numhead-1,0));
if arg.numhead>0
    fn = strread(char(first),'%s', 'delimiter','\t');
    fn = validvar(fn,'_');
else
    tmp = strread(char(first),'%s', 'delimiter','\t');
    fn = gen_labels(size(tmp,1) ,'COL');
end

nf=length(fn);
data=cell(nf,1);
fmt=repmat('%s',1,nf);
% no comments allowed
[data{:}]=textread (sinfile,fmt,'delimiter','\t','headerlines', max(arg.numhead,0), 'bufsize',50000);

nrec = length(data{1});
for ii=1:nf
    if isequal(arg.version,'legacy')
        sins.(fn{ii})=data{ii};
    else
        [sins(1:nrec,1).(fn{ii})] = data{ii}{:};
    end
end

if (docheck)
    %check for syntax errors
    confess(sins);
end
