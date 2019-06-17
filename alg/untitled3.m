function [pvals, rf_obj, enr_obj] = consensus_targets(x,y,doClass)

% x is n by p
% y is n by q

% for each target depending on doClass, generate enr fit and rf fit,
% estimate a pvalue for every rf fit given enr null cases

[n,p] = size(x); 
[~,q] = size(y); 

rf_obj = cell(1,q); 
enr_obj = zeros(p+1,q); 
pvals = zeros(q,1); 
rsq = zeros(q,1); 
isENRnull = zeros(q,1); 
h = waitbar(0,['...building models for ',num2str(q),' outcomes...']); 
for i = 1 : q
    
    switch doClass
        case 'class'
            rf_obj{i} = TreeBagger(300, x, y(:,i),'oobvarimp','on',...
                'options',statset('useparallel','always')); 
            [~,yhat] = oobPredict(rf_obj{i}); 
            [tpr,fpr] = roc(y(:,i)', yhat(:,2)'); 
            rsq(i) = AUC(fpr, tpr); 
            [b,fitinfo] = lassoglm(zscore(x), y, 'binomial','mcreps',5,...
                'options',statset('useparallel','always'),'alpha',0.8,...
                'CV',10) ; 
            if ~any(b(:,fitinfo.Index1SE))
                isENRnull(i) = 1; 
            end
            enr_obj(:,q) = [fitinfo.Intercept(fitinfo.Index1SE) ; ...
                b(:,fitinfo.Index1SE)]; 
        case 'reg'
            rf_obj{i} = TreeBagger(300, x, y(:,i),'oobvarimp','on',...
                'options',statset('useparallel','always'),...
                'method','regression'); 
            rsq(i) = corr(y(:,i),oobPredict(rf_obj{i}),'type','spearman'); 
            [b,fitinfo] = lasso(zscore(x), y, 'mcreps',5,...
                'options',statset('useparallel','always'),'alpha',0.8,...
                'CV',10) ; 
            if ~any(b(:,fitinfo.Index1SE))
                isENRnull(i) = 1; 
            end
            enr_obj(:,q) = [fitinfo.Intercept(fitinfo.Index1SE) ; ...
                b(:,fitinfo.Index1SE)]; 

            
    end
    waitbar(i/q, h); 
end
close(h); 

