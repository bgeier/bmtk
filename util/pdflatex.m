% PDFLATEX Wrapper for pdflatex binary.
% PDFLATEX(TEXFILE) Runs pdflatex with TEXFILE as input.
%
% PDFLATEX(TEXFILE, 'PARAM1', val1, 'PARAM2', val2, ...) specifies optional
% parameter name/value pairs.
%
% '-cleanup'        boolean [true, (false)]
% '-pdflatex_bin'   string ['/path/to/pdflatex']. Defaults:
%                   /usr/bin/pdflatex (Unix), /sw/bin/pdflatex (Mac)
% '-bibtex_bin'     string ['/path/to/bibtex']. Defaults:
%                   /usr/bin/bibtex (Unix), /sw/bin/bibtex (Mac)
%
% Note: pdflatex must be installed on the system.

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function pdflatex(texfile, varargin)

pnames = {'-cleanup','-pdflatex_bin', '-bibtex_bin'};
dflts = {false, '/Library/TeX/texbin/pdflatex', '/Library/TeX/texbin/bibtex'};
arg = getargs2(pnames, dflts, varargin{:});

% path to pdflatex and bibtex binaries
if ~isempty(arg.pdflatex_bin)
    if isfileexist(arg.pdflatex_bin)
        pdflatex_bin = arg.pdflatex_bin;
    else
        error('pdflatex not found at:%s', arg.pdflatex_bin)
    end
else
%     pdflatex_bin = '/usr/bin/pdflatex';
% elseif ismac
%     pdflatex_bin = '/sw/bin/pdflatex';    
% elseif isunix
%     pdflatex_bin = '/usr/bin/pdflatex';
end

if ~isempty(arg.bibtex_bin)
    if isfileexist(arg.bibtex_bin)
        bibtex_bin = arg.bibtex_bin;
    else
        error('bibtex not found at:%s', arg.bibtex_bin)
    end
elseif ismac    
    bibtex_bin = '/sw/bin/bibtex';
elseif isunix    
    bibtex_bin = '/usr/bin/bibtex';
end

if ~isfileexist(pdflatex_bin)
    error ('pdflatex not found at:%s', pdflatex_bin);
end

if ~isfileexist(bibtex_bin)
    error ('bibtex not found at:%s', bibtex_bin);
end


if exist('texfile','var') && isfileexist(texfile)
    [filepath, file, ext]=fileparts(texfile);
    currdir = pwd;
    if isempty(filepath)
        filepath=currdir;
    end
    
    cd(filepath);
    latexcmd = sprintf ('%s -interaction=batchmode "%s" -output-directory="%s"', pdflatex_bin, file, filepath);
    bibtexcmd = sprintf ('%s "%s" ', bibtex_bin, file, filepath);
    system(latexcmd);
    system(bibtexcmd);
    system(latexcmd);
%     system(latexcmd);
    
    cd(currdir);
    
    if arg.cleanup
        cleanup_tex(texfile);
    end
end
