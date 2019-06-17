% GENESYM2PS Convert Affymetrix probeset ids to gene symbols
%   PS = GENESYM2PS(GS)
%   PS = GENESYM2PS(GS,...)
% Human chips:
% HG_U133A, HG_U133AAOFAV2, HG_U133A_2, HG_U133B, HG_U133_Plus_2

function ps = genesym2ps(gs, varargin)

pnames = {'-chip', '-annpath', '-dlm'};
dflts = {'HG_U133A', '/xchip/cogs/ftp/pub/gsea/annotations/', ' /// '};
arg = getargs2(pnames, dflts, varargin{:});
annfile = fullfile(arg.annpath, sprintf('%s.chip', upper(arg.chip)));

if isfileexist(annfile)
    ann = parse_sin(annfile, 0);
    if ischar(gs)
        gs = {gs};
    end
    
    ps = cell(length(gs), 1);
    for ii=1:length(gs)
        ps{ii} = print_dlm_line2(sort(ann.Probe_Set_ID(strmatch(gs{ii}, ann.Gene_Symbol, 'exact'))), '-dlm', arg.dlm);
    end
else
    error('Annotation File not found: %s', annfile);
end


