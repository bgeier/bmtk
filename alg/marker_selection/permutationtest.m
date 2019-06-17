function [pvalue,observedStat,permedStat] = permutationtest(x,y,show)

B = 1000; 


if nargin == 2
    show = 1; 
end

spopen() ; 

observedStat = abs(computeS2N(x,y,1)); 
if show
    fprintf(1,'%s\n',horzcat('Running permutaiton test')); 
    fprintf(1,'%s\n',horzcat('x: num_samples=',num2str(size(x,1)),...
        '   num_features=',num2str(size(x,2)))); 
    fprintf(1,'%s\n',horzcat('y: num_samples=',num2str(size(y,1)),...
        '   num_features=',num2str(size(y,2)))); 
end

data = [x ; y]; 
x_size = size(x,1); 
y_size = size(y,1); 
permedStat = zeros(size(x,2),B); 
ix = logical(reshape(randsample([1 0],size(data,1)*B,true,...
    [x_size/length(data),y_size/length(data)]),size(data,1),B)); 
    
parfor i = 1 : B
    permedStat(:,i) = abs(computeS2N(data(ix(:,i),:),data(~ix(:,i),:),1)); 
end

pvalue = zeros(size(data,2),1); 
parfor i = 1 : length(pvalue)
    [f,x_e] = ecdf(permedStat(i,:)); 
    [~,floc] = min(abs(observedStat(i)-x_e)); 
    pvalue(i) = 1 - f(floc); 
end

observedStat = computeS2N(x,y,1); 

end


function s2n = computeS2N(x,y,fix_low)

if fix_low
    
    s2n = (mean(x) - mean(y))./(fixstd(x) + fixstd(y)); 
    
else
    
    s2n = (mean(x) - mean(y))./(std(x) + std(y)); 
    
end

end

function s = fixstd(x)

min_stdev = 0.2; 

if min_stdev*mean(x) == 0
    minallowed = min_stdev ; 
else
    minallowed = min_stdev*mean(x); 
end

if minallowed < std(x)
    s = std(x); 
else
    s = min_stdev; 
end

end