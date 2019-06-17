function cvMSE = estimateRegfCVmse(X,y,k)
% This function will estimate the expected mse of a regression function
% using a predefined configuration.
% see also pptp_drug_eval_proto

if nargin == 2
    k = 10; 
end

cp = cvpartition(length(y),'kfold',k); 

cvMSE = zeros(1,k); 

for i = 1 : k
    y_i = y(cp.training(i)); 
    x_i = X(:,cp.training(i)); 
    R = train_model(y_i(:)',x_i,'lspinv'); 
    yhat = R*[ones(1,sum(cp.test(i))) ; X(:,cp.test(i) ) ]; 
    cvMSE(i) = mse(y(cp.test(i)) - yhat(:) ); 
end
cvMSE = mean(cvMSE); 