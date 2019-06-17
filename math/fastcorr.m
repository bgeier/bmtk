function R = fastcorr(x,varargin)
% FASTCORR A fast convulsion based method for computing
% correlations
%    R = fastcorr(x,varargin) will try to compute the correlation
%    matrix. See Gentle, J.E. Matrix Algebra. As the number of
%    dimensions increase the numerical inaccuracy also
%    increases. At exist, a test is performed to see if inaccuracy
%    is present. 
pnames = {'-precision'}; 

dflts = {4}; 

arg = getargs2(pnames,dflts,varargin{:});

d = std(x) ;
num_variables = length(d); 

D_inv = eye(num_variables); 
D_inv(logical(D_inv))=1./d;
R = D_inv*cov(x)*D_inv ;
R(R>1) = 1; 
R(R<-1) = -1; 
R = roundn(R,-arg.precision); 
if ~isequal(tril(R),triu(R)')
    fprintf(1,'%s\n','Correlation Numerical Inaccuracy Present....returning triu'); 
    R = triu(R); 
end