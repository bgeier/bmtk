% BMTKVER Version information for BMTK
%   BMTKVER displays current version information.
%   V = BMTKVER returns a structure containing the version information.

function varargout = bmtkver

if nargout>0
   isArgout=true;
else
   isArgout=false;
end

v = struct('Name', 'Broad Matlab Toolkit', ...
    'Version', '1.1',...
    'Release', 'Americone Dream',...
    'Date', '20-Oct-2010');

if isArgout
    varargout{1} = v;
else
    fprintf('%s Version %s (%s)\n', v.Name, v.Version, v.Release)
end
