function cl = bayesMethodPlusFilter(xtest,xtrain,ytrain)

pval = mattest(xtrain(:,strcmp('Success',ytrain)),...
    xtrain(:,strcmp('Fail',ytrain)),'Bootstrap',3000); 
show = pval < 0.01; 
cl = knnclassify(xtest(:,show),...
    xtrain(:,show),ytrain) ;