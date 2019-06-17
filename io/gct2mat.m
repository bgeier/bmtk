function gct2mat(varargin)

toolName = mfilename ; 
dflt_out = get_lsf_submit_dir ; 
pnames = {'-gct','-out'};
dflts = {'',dflt_out};
arg = getargs2(pnames,dflts,varargin{:}); 
print_tool_params2(toolName,1,arg); 

[ge,gn,gd,sid] = parse_gct(arg.gct); 

ge = double(ge); 

print_str(horzcat('Saving mat conversion to ',...
    fullfile(arg.out,pullname(arg.gct))))
save(fullfile(arg.out,pullname(arg.gct)),'ge','gn','gd','sid') ;