
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:47 EDT
function wellidx = well2idx(wn, varargin)

pnames = {'platefmt'};
dflts = {'384'};
arg = getargs2(pnames, dflts, varargin{:});
if ischar(wn)
    wn = {wn};
end

switch arg.platefmt
    case '384'
        % 384 well fmt
        wellfmt = parse_sin(mapdir('/Volumes/xchip_cogs/matlib/resources/384_plate.txt'), false);
        colord = str2double(wellfmt.COLMAJOR_ORDER);        
        [cmn, idx] = intersect_ord(wellfmt.WELL, wn);
        if ~isequal(cmn, wn)
            disp(setdiff(wn, cmn));
            error('Well info could not be extracted for some wells');
        else
            wellidx = colord(idx);
        end
    otherwise
        error('Unknown platefmt: %s', arg.platefmt);
end


