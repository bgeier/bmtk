function yhat = buildENRmodel(xtest,xtrain,ytrain,k)
% An elastic net regression model will identify the variables most
% predictive of response. The value k is the regularization applied [0,1]. 

[~,p] = corr(xtrain,ytrain); 

xtrain = xtrain(:,p<0.01); 
xtest = xtest(:,p<0.01); 

[b,info] = lasso(xtrain,ytrain,'alpha',k,'CV',10); 

hits = abs(b(:,info.Index1SE)) > 0; 

print_str([num2str(sum(hits)),' in model']); 


if sum(abs(b(:,info.Index1SE))>0) ~= 0
    yhat = xtest*b(:,info.Index1SE); 
else
    print_str('no features in final model'); 
    yhat = mean(ytrain)*ones(size(xtest,1),1); 
end