function pct = overlap(a,b)
% OVERLAP Compute the percentage that a overlaps with b
% 
% Author: Brian Geier, 2011

pct = round((length(intersect(a,b))/length(b))*100) ;
