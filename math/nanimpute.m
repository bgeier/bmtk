function [y,idx] = nanimpute(x,method_type)
% NANIMPUTE Impute missing data
%   [y,idx] = NANIMPUTE(x,method_type) will impute missing values using 
%   column descriptive statistics, based on either mean, min, median or a
%   variation of multiple ordered value imputation (movi). mean and median
%   imputation are useful if data is missing at random. min imputation is a
%   naive fill in technique for left censored data. movi is a left censored
%   missing data imputation that preserves the underlying distribution tail
%   given a kernel density estimate of the full data. the movi operation
%   encloses the tail of a kernel density estimate with a rectangle of
%   uniformly distributed data and then draws random variables if the
%   evaluted (by ksdensity) uniform falls below an orthogonal uniform. 
%   Inputs: 
%       x : a matrix of data, p by n if gcms, n by p for most other cases.
%       Note, data imputation will be based on column wise operation, and
%       the dimension of x should reflect
%       method_type : a string indicating the type of imputation to
%       perform. can be either 'mean', 'min', 'median',' movi'
%   Output: 
%       y : a matrix of original data with missing data filled in
%       idx : an indicator matrix for imputed values
% 
% Author: Brian Geier, RHXBC Jul 26, 2017

% go column by column, set nan to mean value
if nargin == 1
    method_type = 'mean'; 
end

idx = isnan(x); 

switch method_type
    case 'mean'
        y = x; 
        if any(isnan(y(:)))
            for i = 1 : size(y, 2)
                y(isnan(y(:,i)), i) = nanmean(y(:,i)); 
            end
        end
    case 'min'
        y = x; 
        if any(isnan(y(:)))
            for i = 1 : size(y, 2) % go columnwise
                y(isnan(y(:,i)), i) = min(y(:,i)) - rand(); 
            end
        end
    case 'median'
        y = x; 
        if any(isnan(y(:)))
            for i = 1 : size(y, 2)
                y(isnan(y(:,i)), i) = nanmedian(y(:,i)); 
            end
        end
    case 'movi'
        % establish an internal order below LoQ within a sample
        y = x; 
        % assume that the measurement is normal, randomly generate new
        % values below the lowest observed quantile
        r = rand(10000,2,size(y,2)); h = waitbar(0,'...'); 
        for i = 1 : size(y, 2)
            if ~any(isnan(y(:,i))), continue, end
            y(:,i) = rankandfill(y(:,i), squeeze(r(:,:,i))); 
            waitbar(i/size(y, 2), h); 
        end
        close(h); 
    otherwise 
        print_str('unsupported method type'); 
        y = [];

end


function y = rankandfill(x,r)

% x is observation vector of gcms measurements
% r is source of random deviates to draw from, r is bivariate U[0,1]xU[0,1]

y = x; 
lookup = ~isnan(x); 
x = zscore(x(lookup)); 

% if cdf is specified, then we can draw low end for any distribution to
% include heavy tailed or alpha stable distribution functions
% p = normcdf(x); 

% the boundary at which to do accept/reject sampling based on a pair of
% orthogonal uniforms between [0,x_lower_boundry],[0,lowest_q]
x_lower_boundry = -1.75;% min(x); 

sigma = min(std(x), iqr(x)/1.34); 

[ff,xx] = ksdensity(x,'bandwidth',1.06*sigma*(length(x).^(-1/5))); 

[~,i] = min(xx); 

lowest_q = ff(i); 

abs_low = min(-3,min(xx)); 

r_x = r(:,1).*(x_lower_boundry - abs_low ) + abs_low ;
r_y = r(:,2).*lowest_q; 

% a box enclosing tail region

keep = r_y <= ksdensity(x, r_x) ;  

rvs = r_x(keep); 

if sum(keep) < sum(isnan(x))
    error(['n = ',num2str(sum(isnan(x))),' but N=',...
        num2str(sum(keep))]); 
end

y(isnan(y)) = rvs(1:sum(isnan(y)))*nanstd(y) + nanmean(y); 
