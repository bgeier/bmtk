function y = safelog(x)

x(x<=0) = eps; 
y = log(x); 