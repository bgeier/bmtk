function [r,p] = nancorr(x,y,corr_type)

if nargin == 2
    corr_type = 'pearson'; 
end

drop = any(isnan(x),2) | any(isnan(y),2); 

x(drop,:) = []; y(drop,:) = [];

[r,p] =corr(x,y,'type',corr_type); 