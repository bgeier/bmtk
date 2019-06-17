function gs = ps2genesym(ps, varargin)

pnames = {'-chip', '-annpath', '-desc'};
dflts = {'HG_U133A', '/xchip/cogs/ftp/pub/gsea/current/', false};
arg = getargs2(pnames, dflts, varargin{:});
annfile = fullfile(arg.annpath, sprintf('%s.chip', arg.chip));

if isfileexist(annfile)
    ann = parse_sin(annfile, 0);
    if ischar(ps)
        gs = ann.Gene_Symbol(strmatch(ps, ann.Probe_Set_ID, 'exact'));
        if arg.desc && ~isempty(gs)
            gs = strcat('gene=',gs,'|desc=',ann.Gene_Title(strmatch(ps, ann.Probe_Set_ID, 'exact')));
        end
    else
        [cmn, ia] = map_ord(ann.Probe_Set_ID, ps);
        gs = ann.Gene_Symbol(ia);
        if arg.desc && ~isempty(gs)
            gs = strcat('gene=',gs,'|desc=',ann.Gene_Title(ia));
        end
    end
end


