function events = consolidate_events(events)

exonic = {'frameshift deletion','frameshift insertion',...
    'nonframeshift deletion','nonframeshift insertion',...
    'synonymous SNV','frameshift substitution',...
    'nonframeshift substitution'};
for i = 1 : length(exonic)
    events(strcmp(exonic{i},events)) = {'exonic'} ;
end

utr = {'UTR3','UTR5','UTR5;UTR3'}; 
for i =  1 : length(utr)
    events(strcmp(utr{i},events)) = {'UTR'} ;
end

events(strcmp('upstream',events)) = {'upstream;downstream'}; 
events(strcmp('downstream',events)) = {'upstream;downstream'}; 
