% MKWORKFOLDER Create work and analysis folders with date and timestamps
%   NEWDIR = MKWORKFOLDER creates a folder in the current working
%   directory at PWD/MMMDD, where MMM is the 3 letter month code and DD is
%   the 2 digit day number.
%   
%   NEWDIR = MKWORKFOLDER(PARENT) creates a folder under PARENT.
%
%   NEWDIR = MKWORKFOLDER(PARENT, PREFIX) creates an analysis subfolder
%   under parent at PARENT/PREFIX_HHMMSS, where HH, MM and SS are the
%   current hour, minute and seconds returned by NOW.
%   NEWDIR = MKWORKFOLDER(PARENT, PREFIX, FORCESUFFIX) Forces suffix
%   generation if FORCESUFFIX is true, otherwise attempts to create folder
%   without suffix first.

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT
function newfolder = mkworkfolder(pfolder, prefix, forcesuffix)

s=init_rand_state;

if (~exist('pfolder','var'))
   pfolder = pwd;
end
 
if (~exist('prefix','var'))
    prefix = 'my_analysis';
end
if (~exist('forcesuffix','var'))
    forcesuffix = true;
end
% seems to fix race condition
% pause(1);

if (exist (pfolder,'dir'))
if forcesuffix
    uniquedir = 0;
else
    % try without suffix
    newfolder = fullfile(pfolder, prefix);
    uniquedir= ~isfileexist(newfolder, 'dir');
end
while (~uniquedir)
    pause(3*rand);
    newfolder = genfoldername(pfolder, prefix);
    %is it unique?
    uniquedir = ~isfileexist(newfolder,'dir');    
  end
    
  [success, msg] = mkdir (newfolder);
  %fprintf ('%s %d %s\n',newdir, success, msg);
    
else
    error('rnlib:mkworkfolder path %s not found\n', pfolder);
end

function newfolder = genfoldername(pfolder, prefix)

% try using the LSF jobid as suffix
jid = get_lsf_jobid;
if ~isempty(jid)
  suffix=jid;
else
  %create one manually
  
  suffix = sprintf ('%s%d', lower(datestr(now,'mmm.dd.HHMMSS')),round(rand*100));
end

newdir = sprintf ('%s.%s',prefix, suffix);
newfolder = fullfile(pfolder, newdir);
