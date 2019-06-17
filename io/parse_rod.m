function rod_struct = parse_rod(fname,delim)
% PARSE_ROD     Parse *.rod file
% NOT USED
% Author: Brian Geier, PPTP 2011


if nargin == 1
    delim = '%u%s%s%s%f%f%f%f%u%s%s%f%s%s%s%s'; 
end
fid = fopen(fname); 
c = textscan(fid,delim,'Delimiter','\t'); 
fclose(fid); 



rod_struct.accession_id = c{2}; 
rod_struct.chromosome = c{3}; 
rod_struct.start = c{5}; 
rod_struct.end = c{6}; 
