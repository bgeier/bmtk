function p = rf_pval(B,num_iterations)


% B is TreeBagger structure

% permute y many times to estimate a null performance distribution

if nargin == 1
    num_iterations = 500; 
end

null_perf = zeros(1,num_iterations); 

[~,rdx] = sort(rand(length(B.Y), num_iterations)); 
% h = waitbar(0,'computing RF type I error'); 

if num_iterations < 30
    h = waitbar(0,'computing RF type I error'); 
    for i = 1 : num_iterations
        b = TreeBagger(50, B.X, B.Y(rdx(:,i)), 'oobvarimp','on','method',...
            B.Method,'options',statset('useparallel','always'));
        null_perf(i) = updateNull(b,B); % B tracks the original response
        waitbar(i/num_iterations, h); 
    end
    close(h); 
    
else
    % faster to parallelize outer loop
    parfor i = 1 : num_iterations
        b = TreeBagger(50, B.X, B.Y(rdx(:,i)), 'oobvarimp','on','method',...
            B.Method,'options',statset('useparallel','always'));
        null_perf(i) = updateNull(b,B); 

    %     waitbar(i/num_iterations, h); 
    end
end

% close(h); 

if num_iterations < 30
    p = 1 - normcdf(updateNull(B,B), mean(null_perf), std(null_perf)); 
else
    p = 1 - getpvalue(null_perf, updateNull(B,B)); 
end

function perf = updateNull(b,B)

switch B.Method
    case 'regression'
        perf = max(0,corr(oobPredict(b), B.Y)); 
    case 'classification'
        [~,yhat] = oobPredict(b); 
        [tpr,fpr] = roc(str2double(B.Y)', yhat(:,2)'); 
        perf = AUC(fpr,tpr); 
    otherwise
        error('unsupported method...'); 
end