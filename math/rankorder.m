% RANKORDER Compute rank order of elements in a matrix.
%   RNK = RANKORDER(M)
%   Ranks are computed by sorting M in ascending order along each column.
%
%   RANKORDER(M,'dim',DIM) sorts M along dimension DIM. DIM can be 1 or 2
%   (is 1 by default). 
%
%   RANKORDER(M,'direc', DIREC) sorts M in ascending or
%   descending order. DIREC can be 'ascend or 'descend' (is 'ascend' by
%   default). 
%
%   RANKORDER(M,'zeroindex', ISZEROINDEX) Returned ranks are zero
%   or one indexed. ISZEROINDEX is boolean (is false by default).
%
%   RANKORDER(M,'fixties', FIX) Adjusts for ties FIX is boolean (is true by
%   default). 

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

% Changes: wrapper for tiedrank now

function rnk = rankorder(m, varargin)

% nin=nargin;
% error(nargchk(1,3,nin,'struct'));

% breakties = false;

pnames = {'dim','direc','zeroindex','fixties'};
dflts = {1, 'ascend',false,true};
arg = getargs2(pnames, dflts, varargin{:});

if arg.fixties
    rank_alg = @tiedrank;
else
    rank_alg = @myrankorder;
end

if ndims(m)<=2
    
    switch lower(arg.direc)
        case 'ascend'
            rnk = rank_alg(m);
        case 'descend'
            rnk = rank_alg(-m);
        otherwise
            error ('Invalid direc specified: %s', arg.direc);
    end
    
    if arg.zeroindex
        rnk = rnk-1;
    end
    % old code
    %     [nr, nc]= size(m);
    %     nel= size(m, arg.dim);
    %     ord = (1:nel)';
    %     [sm, sidx] = sort(m, arg.dim, arg.direc);
    %     [a, ia] = sort(sidx, arg.dim);
    %     rnk = ord(ia);
    %
    %     %break ties
    %     %TOFIX , currently only deals with <=2 identical vals
    %     if breakties
    %         if isequal(arg.dim,1)
    %             z = find(diff([sm; nan(1,size(sm, 2))])==0);
    %         else
    %             z = find(diff([sm, nan(size(sm,1), 1)])==0);
    %         end
    %         y=sidx+repmat((0:nc-1)*nr,nr,1);
    %         tiernk = 0.5*(rnk(y(z+1))+rnk(y(z)));
    %         rnk(y(z)) = tiernk;
    %         rnk(y(z + 1)) = tiernk;
    %     end
    
else
    error('Input should have <=2 dimensions')
end
end

% Compute ranks for matrix m along the first dimension
% Does not adjust for ties
function rnk = myrankorder(m)
[nr, nc]= size(m);
nel= size(m, 1);
ord = (1:nel)';
[sm, sidx] = sort(m,1);
[a, ia] = sort(sidx,1);
rnk = ord(ia);
end
