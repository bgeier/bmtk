function titv = compute_titv(ref,obs)

transitions = {'C', 'T' ; 'A', 'G' ; 'G' , 'A' ; 'T', 'C'};
tranversions = {'A','C','T'; 'G', 'C' , 'T' ; 'C', 'A', 'G' ; ... 
    'T','A','G'}; 


ti = zeros(size(transitions,1),1); 
for i = 1 : length(ti)
    ti(i) = sum(strcmp(transitions{i,1},ref) & ...
        strcmp(transitions{i,2},obs) ) ; 
end
tv = zeros(size(tranversions,1),1); 
for i = 1 : length(tv)
    tv(i) = sum(strcmp(tranversions{i,1},ref) & ( ...
        strcmp(tranversions{i,2},obs) | strcmp(tranversions{i,3},obs) )); 
end
titv = sum(ti)/sum(tv) ; 