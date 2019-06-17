function y = safelog2(x)

x(x<=0) = NaN; 
y = log2(x); 