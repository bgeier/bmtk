% map mac folders to unix and vice versa

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT

function name = mapdir(fname)

name = fname;
if ~isempty(name)
    if (ismac)
        % Volumes not appended already
        ismatch = regexp(name, '^/Volumes(/.+)','start');
        if (isempty(ismatch))
            [s,r] = strtok(name,'/');
            name = ['/Volumes/',s,regexprep(r,'/','_','once')];
        end
    elseif (isunix)
        [ismatch, tok] = regexp(name, '^/Volumes(/.+)', 'start','tokens');
        if (~isempty(ismatch))
            name = char(regexprep(tok{1},'_','/','once'));
        end
    else
        disp ('Unknown folder mapping for current platform');
    end
end