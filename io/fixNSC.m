function nsc_str = fixNSC(nsc_str)

nsc_str(strcmp('RXF 393',nsc_str)) = {'RXF_393'};
nsc_str(strcmp('NCI/ADR-RES',nsc_str)) = {'NCI_ADR_RES'};
nsc_str(strcmp('T-47D',nsc_str)) = {'T47D'};


for i = 1 : length(nsc_str)
    tmp = nsc_str{i} ; 
    tmp(isspace(tmp)) = [];
    ix = find(tmp=='('); 
    if ~isempty(ix)
        tmp(ix(1):end) = [];
    end
    ix = find(tmp=='/'); 
    if ~isempty(ix)
        tmp(ix(1):end) = [];
    end
    nsc_str{i} = tmp; 
end
nsc_str = undashit(nsc_str); 