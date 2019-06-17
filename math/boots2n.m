function y = boots2n(x,y)

X = [x,y] ; 
flag = zeros(1,size(X,2)); 
flag(1:length(x)) = 1; 
flag(flag==0) = 2; 

y = s2n(X,flag,2,false); 