% SAVEFIGURES Save currently open figures to file

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT
function figlist = savefigures(varargin)

toolName = mfilename;
pnames = {'-fmt', '-out' , '-mkdir', '-sortord','-exclude'};
dflts = {'png', '.', true, true, []};
arg = getargs2(pnames,dflts,varargin{:});
[hf, ord] = setdiff(findobj('type', 'figure'), arg.exclude);
% sorted by default
if ~arg.sortord
    hf = hf(sort(ord));
end
nf = length(hf);
figlist=cell(nf,1);

%search these fields for a label
namefields = {'name','tag'};

%create sub folder by default
if arg.mkdir
    wkdir = mkworkfolder(arg.out, toolName);
    
else
    wkdir = arg.out;
end

fprintf ('Saving figures to %s\n',wkdir);
for ii=1:nf
    
    for jj=1:length(namefields);
        lbl = get(hf(ii), namefields{jj});        
        if ~isempty(lbl) 
            break; 
        end
    end
    if isempty(lbl)
        lbl = sprintf('figure_%d',hf(ii));      
    end
    
    figlist{ii} = fullfile(wkdir, sprintf('%s.%s',lbl,arg.fmt));
    fprintf('%s\n',figlist{ii});
    saveas(hf(ii), figlist{ii});
    
end
