function pvals = consensus_targets(x,y,doClass)

% x is n by p
% y is n by q

% for each target depending on doClass, generate enr fit and rf fit,
% estimate a pvalue for every rf fit given enr null cases

[~,q] = size(y); 

% rf_obj = cell(1,q); 
% enr_obj = zeros(p+1,q); 
pvals = NaN(q,1); 
rsq = zeros(q,1); 
isENRnull = zeros(q,1); 

h = waitbar(0,['...building models for ',num2str(q),' outcomes...']); 
for i = 1 : q
    [rsq(i), isENRnull(i)] = check_perf(x, y(:,i), doClass{i}); 
    
    waitbar(i/q, h); 
end
close(h); 

if all(isENRnull)
    print_str('all NULL'); 
    return
end
    
if any(strcmp('class',doClass))
    pvals(strcmp('class',doClass)) = 1 - getpvalue(rsq(strcmp('class',doClass) & ...
        isENRnull==1), rsq(strcmp('class',doClass))); 
end

if any(strcmp('reg',doClass))
    pvals(strcmp('reg',doClass)) = 1 - getpvalue(rsq(strcmp('reg',doClass) & ...
        isENRnull==1), rsq(strcmp('reg',doClass))); 
end


function [rsq, isNull, rf_obj, enr_obj] = check_perf(x, y,doClass)

isNull = 0; 
num_trees = 50; 


switch doClass
    case 'class'
        rf_obj = TreeBagger(num_trees, x, y,'oobvarimp','on',...
            'options',statset('useparallel','always')); 
        [~,yhat] = oobPredict(rf_obj); 
        [tpr,fpr] = roc(y', yhat(:,2)'); 
        rsq = AUC(fpr, tpr); 
        [b,fitinfo] = lassoglm(zscore(x), y, 'binomial','mcreps',5,...
            'options',statset('useparallel','always'),'alpha',0.8,...
            'CV',10) ; 
        if ~any(b(:,fitinfo.Index1SE))
            isNull = 1; 
        end
        enr_obj = [fitinfo.Intercept(fitinfo.Index1SE) ; ...
            b(:,fitinfo.Index1SE)]; 
    case 'reg'
        rf_obj = TreeBagger(num_trees, x, y,'oobvarimp','on',...
            'options',statset('useparallel','always'),...
            'method','regression'); 
        rsq = corr(y,oobPredict(rf_obj),'type','spearman'); 
        [b,fitinfo] = lasso(zscore(x), y, 'mcreps',5,...
            'options',statset('useparallel','always'),'alpha',0.8,...
            'CV',10) ; 
        if ~any(b(:,fitinfo.Index1SE))
            isNull = 1; 
        end
        enr_obj = [fitinfo.Intercept(fitinfo.Index1SE) ; ...
            b(:,fitinfo.Index1SE)]; 


end

