function ds = parse_gct_multi(fn, varargin)

dsfile = parse_filename(fn, '-wc', '*.gct');
nds = length(dsfile);
ds = struct('ge',[],'gn',[],'gd',[],'sid',[]);
for ii=1:nds
    [ds(ii).ge, ds(ii).gn, ds(ii).gd, ds(ii).sid] = parse_gct(dsfile{ii}, varargin{:});
end
