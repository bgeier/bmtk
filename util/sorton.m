% SORTON Sort array on multiple keys
% SORTON(X)
% SORTON(X, KEY)
% SORT(X, KEY, DIM)
% SORT(X, KEY, DIM, MODE)
% NOTE: Currently works for 2d arrays only
% Example:
% x=[4, 2;  3, 7;  3, 1;  5, 6]
% [s,ii]=sorton(x,[1,2],1,{'ascend','descend'})
%

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT
function [s, varargout] = sorton(X, KEY, DIM, MODE)

nin=nargin;
nargchk(2,4,nin);
nout = max(nargout,1)-1;

size(X);

if ~exist('KEY','var')    
   KEY=1;
else
    
end

if ~exist('DIM','var')    
   DIM=1;
end

if ~exist('MODE','var')
    MODE = 'ascend';  
end

if isequal(DIM,2)
    X = X';
end

ord = (1:size(X, DIM))';
nkey = length(KEY);

for ii=nkey:-1:1
    
    if iscell(MODE)
        thisMODE = MODE{ii};
    else
        thisMODE = MODE;
    end
    
    [sx, idx] = sort(X(ord, KEY(ii)), DIM, thisMODE);
    ord = ord(idx);
end

if isequal(DIM,1)
    s = X(ord,:);
else
    s = X(ord,:)';
end
for ii=1:nout
    varargout(ii) = {ord};
end
