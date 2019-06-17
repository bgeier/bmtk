function ci_vals = compute_rf_var_ci(B)
% COMPUTE_RF_VAR_CI     Compute Confidence Intervals for Random Forest xi
%   ci_vals = COMPUTE_RF_VAR_CI(B) takes the random forest object, B,
%   generates the per tree oob var delta error ( a private nonaccessible
%   property within B ) and estimates a confidence interval via bootstrap.
%   The default bias corrected and accelerated bootstrap confidence
%   interval is applied with type I error at 5%. 
% Inputs: 
%   B : random forest object returned by TreeBagger.m, oobvarimp does not
%   need to be true
% 
% Outputs: 
%   ci_vals : p by 2 matrix listing lower and upper confidence interval
%   limits by bootstrap
% 
% see also TreeBagger, CompactTreeBagger


x = B.X; 
y = B.Y; 
w = B.W; 

s = RandStream.getGlobalStream;

ntrees = B.NTrees; 
nvars = size(x, 2); 
nboot = 3000; 

ci_vals = NaN(nvars, 2); 

oob_delta_error = zeros(ntrees, nvars); 

h = waitbar(0,['compute delta error across ',num2str(ntrees),' trees']); 
for i = 1 : ntrees
    oob_delta_error(i,:) = oobPermVarUpdate(x, y, w, B.ClassNames, ...
        B.compact, i, B.OOBIndices(:,i), false, s); 
    waitbar(i/ntrees,h); 
end
close(h); 

fun = @(x) nanmean(x)./nanstd(x) ; % Leo Brieman test statistic for variable importance

h = waitbar(0,['compute metric ci for ',num2str(nvars),' variables']); 
for i = 1 : nvars
    if isinf(fun(oob_delta_error(:,i))) || isnan(fun(oob_delta_error(:,i)))
        continue
    end
    ci_vals(i,:) = bootci(nboot, {fun, oob_delta_error(:,i)},'options',...
        statset('useparallel','always')); 
    waitbar(i/nvars,h); 
end
close(h); 

end

function slicedPrivOOBPermutedVarDeltaError = ...
    oobPermVarUpdate(x,y,w,classNames,compact,compactInd,oobtf,doclassregtree,s)

% all is taken or modified from TreeBagger main routine

% oobPermVarUpdate:
% The output arguments correspond to TreeBagger Properties
% PrivOOBPermutedVarDeltaError, PrivOOBPermutedVarDeltaMeanMargin,
% and PrivOOBPermutedVarCountRaiseMargin, respectively.
% They are supplied as return values because in situ assignments
% to class properties cannot be done in a parfor context.

% Permute values across each input variable
% and estimate decrease in margin due to permutation
Nvars = size(x,2);

% Preallocate the output arguments
slicedPrivOOBPermutedVarDeltaError = zeros(1,Nvars);

% Get oob data
Xoob = x(oobtf,:);

% Get size of oob data
Noob = size(Xoob,1);
if Noob<=1
    return;
end

% Get weights
Woob = w(oobtf);
Wtot = sum(Woob);
if Wtot<=0
    return;
end

% Get non-permuted scores and labels
[sfit,~,yfit] = treeEval(compact,compactInd,Xoob,doclassregtree);

% Get error
doclass = ~isempty(classNames);
if doclass
    err = dot(Woob,~strcmp(y(oobtf),yfit))/Wtot;
else
    err = dot(Woob,(y(oobtf)-yfit).^2)/Wtot;
end

for ivar=1:Nvars
    % Get permuted scores and labels
    permuted = randsample(s,Noob,Noob);
    xperm = Xoob;
    xperm(:,ivar) = xperm(permuted,ivar);
    wperm = Woob(permuted);
    [~,~,yfitvar] = ...
        treeEval(compact,compactInd,xperm,doclassregtree);
    
    % Get the change in error
    if doclass
        permErr = dot(wperm,~strcmp(y(oobtf),yfitvar))/Wtot;
    else
        permErr = dot(wperm,(y(oobtf)-yfitvar).^2)/Wtot;
    end
    slicedPrivOOBPermutedVarDeltaError(ivar) = permErr-err;
end

end

function [scores,nodes,labels] = treeEval(bagger,treeInd,x,doclassregtree)
% method taken from CompactTreeBagger.m
    % Get the tree and classes
    tree = bagger.Trees{treeInd};
    if doclassregtree
        cTreeNames = tree.classname;
    else
        if strcmp(bagger.Method(1),'c')
            cTreeNames = tree.ClassNames;
        else
            cTreeNames = {};
        end
    end
    Nclasses = length(bagger.ClassNames);

    % Empty data?
    if isempty(x)
        scores = NaN(0,max(Nclasses,1));
        nodes = zeros(0,1);
        if Nclasses==0
            labels = scores;
        else
            labels = repmat(bagger.ClassNames{1},0,1);
        end
        return;
    end

    % Compute responses
    if Nclasses==0
        % For regression, get Yfit values
        if doclassregtree
            [scores,nodes] = eval(tree,x);
        else
            [scores,nodes] = predict(tree,x);
        end
        labels = scores;
    else
        % For classification, get class probabilities
        if doclassregtree
            [labels,nodes] = eval(tree,x);
            unmapped = classprob(tree,nodes);
        else
            [labels,~,nodes] = predict(tree,x);
            unmapped = tree.ClassProb(nodes,:);
        end

        % Map classregtree classes onto bagger classes
        cFullNames = bagger.ClassNames;
        nFullClasses = length(cFullNames);
        N = size(x,1);
        scores = zeros(N,nFullClasses);
        [~,pos] = ismember(cTreeNames,cFullNames);
        scores(:,pos) = unmapped;
    end
end