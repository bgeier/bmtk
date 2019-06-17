% CONFESS check sin file for syntax
% CONFESS(SINFILE)
% CONFESS(SINSTRUCT)

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT

function confess(sins)

if ~isstruct(sins)
    sins = parse_sin(sins);
end

nrec = length(sins.NAME);
nfields = length(fields(sins));

%quick check to see if the NAME field is proper
isbad = isempty (str2num(char(sins.NAME)));

if isbad

for ii=1:nrec

    if isempty(str2num(char(sins.NAME{ii})))
        fprintf('Invalid chars:%s in NAME in row %d\n',sins.NAME{ii},ii)
    end
    
end

else
    
    fprintf ('%d instances, %d fields, tested OK\n',nrec,nfields);

end
