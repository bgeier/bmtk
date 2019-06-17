% ES Compute Enrichment score 
%   [ES, HITRANK, HITIND] = COMPUTE_ES(GSET,LI,GN)
%
%   Inputs:
%   GSET    List of labels to test for enrichment specified in GN 
%           [Gx1 cellstr array], OR a vector of indices of GN
%   LI      unsorted list of values in which to test for enrichment
%           [N x C matrix]
%   GN      Labels of rows in LI. Not used if GSET is a vector.
%
%   Outputs:
%   ES         Running Enrichment scores for each column in LI [N x C
%              double array]
%   HITRANK    Rank of each hit 
%   HITIND     Indices of GN for each element of GSET in GN (Gx1 vector)

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT

% Rajiv Narayan askrajiv@gmail.com
% Created 11/12/2007
% History: 12/12/2008 
%           -added to rnlib
%           -

function [es, hitrank, hitind] = es(gset, li, gn, varargin)
          
nargs=nargin;

pnames = {'weight', 'exponent','isranked'};
valides={'classic','weighted'};
dflts =  {'classic',   1, false};

[eid, emsg, midx, weight, p, isranked] = getargs(pnames, dflts, varargin{:});

%check if valid es type
if ~isvalidstr(weight, valides)
    error('Invalid weight: %s\n', weight);
else
    isweighted=isequal(weight,'weighted');        
end

%Total number of genes(N) and instances(C) in cmap
[N,C]=size(li);

%geneset could be an array of indices or a celstr

%Number of genes in geneset
G=numel(gset);

%Enrichment scores (ES) for all instances
%Initialize ES to cost of a miss
es=ones(N,C).*(-1/(N-G));

if (iscell(gset))
    [cmn,hitind] = intersect_ord(gn,gset);
    if ~isequal(G,length(cmn))
        disp('Some genes from set missing');
        disp(setdiff(gset,cmn));
    end
else
    hitind=gset;
end

%get ranks
% IMP ensure rank starts at 1
if ~isranked
    rank = rankorder(li, 'direc','descend', 'zeroindex','false');
else
    rank = li;
end
% [srtli, ord]=sort(li, 'descend');
% rank=zeros(N,C);
% rank(ord + repmat((0:C-1)*N,N,1)) = repmat((1:N)',1,C);

%is equivalent to
% for ii=1:C
%     rank(ord(:,ii),ii) = 1:N;
% end

%this is wrong
% rank(ord)=repmat((1:N)',1,C);

%Ranks of each hit for all instances
hitrank = rank(hitind,:);

%Column indices of all instances for each gene
J=repmat(1:C,G,1);

%Mark hit indices with the cost of a hit


if isweighted
    % weighted ES score    
    x=abs(li(hitind,:)).^p;
    es(hitrank+N*(J-1)) = x ./ repmat(sum(x),G,1);
else    
    %unweighted ES
    % note: p=0 will the give the same result
    es(hitrank+N*(J-1))=1/G;
end

%Running Enrichment score
es=cumsum(es);
