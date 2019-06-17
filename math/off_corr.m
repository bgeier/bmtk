function r = off_corr(x,type)

if nargin == 1
    type = 'pearson'; 
end
r = corr(x,'type',type);
r = triu(r,1); 

r = r(:); 