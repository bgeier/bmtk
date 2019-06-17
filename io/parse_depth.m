function [depth,x] = parse_depth(fname,interval)
% PARSE_DEPTH   Return Median Coverage for the interval
% 
% Author: Brian Geier, 2011 BGC 

fid = fopen(fname); 
C = textscan(fid,'%s%f%f%f%s%s%s%s%s%s',range(interval),'Delimiter','\t',...
    'Headerlines',interval(1)+1); % +1 to take into account header 
fclose(fid); 
depth = median(C{2});
x = C{2}; 