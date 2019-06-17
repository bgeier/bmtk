function results = gather_gsea_rpt(pathname)

paths = dir(pathname); 

wild_cards = {'.','..'}; 
ix = zeros(1,length(paths)); 
for i = 1 : length(paths)
    if any(strmatch(paths(i).name,wild_cards))
        ix(i) = 1; 
    end
end

paths(logical(ix)) = [];

results = struct('gsea_rpt','','class','','isInferred',''); 

for i = 1 : length(paths)
    ix = find(paths(i).name == '.'); 
    id = paths(i).name(ix(end)+1:end); 
    results(i).gsea_rpt = parse_gsea(fullfile(paths(i).name,...
        horzcat('gsea_report_for_na_pos_',id,'.xls'))); 
    results(i).class = paths(i).name(1:ix(1)-1); 
    if ~isempty(strfind(results(i).class,'inf'))
        results(i).isInferred = 1; 
    else
        results(i).isInferred = 0; 
    end
end