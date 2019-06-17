
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT
function h = plot_platemap(x, wells, varargin)

toolName=mfilename;
pnames = {'-title','-colormap'};
dflts = {'', 'jet'};
arg = getargs2(pnames, dflts, varargin{:});

[wn, word] = get_wellinfo(wells);
y=nan(16,24);
y(word)= x;

h = imagesc(y);
% set missing to white
set(h,'alphadata', ~isnan(y));

%row and column names
rn = textwrap({char(64 + (1:16))},1);
cn = num2cellstr(1:24);

set(gca,'xtick', 1:24, 'xticklabel', cn,...
    'ytick', 1:16,'yticklabel', rn,...
    'fontweight', 'bold',...
    'tickdir', 'out')

ha = rotateticklabel(gca,90);
set(ha,'fontweight', 'bold');

if ~isempty(arg.title)
    title(texify(arg.title));
end

colormap(arg.colormap);

colorbar
