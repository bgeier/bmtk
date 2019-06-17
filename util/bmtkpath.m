% BMTKPATH Get location of BMTK library
function p = bmtkpath

if exist('BMTKPATH','var')
    p = BMTKPATH;
else
    p = strrep(which(mfilename), sprintf('/util/%s.m',mfilename), '');
    
end
