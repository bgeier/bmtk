% RMSE  Compute Root mean square error of two vectors.
% E = RMSE(X,Y)
% E = RMSE(X,Y, '-metric', M, '-usemedian', true)
% rmse
% pct_rmse
% nrmse
% cv_rmse
%
%
% See: http://en.wikipedia.org/wiki/Mean_squared_error
% http://en.wikipedia.org/wiki/Root_mean_square_deviation

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

function e = rmse(x, y, varargin)

%convert to column vectors
x=x(:);
y=y(:);

pnames = {'-metric', '-usemedian', '-debug'};
dflts = {'rmse', false, false};
arg = getargs2(pnames, dflts, varargin{:});

if arg.debug
    print_tool_params2(mfilename, 1, arg);
end

if ~isequal(length(x), length(y))
    error('X and Y should have the same dimensions')
end

%mean or median
if arg.usemedian
    middle = @nanmedian;
else
    middle = @nanmean;
end

switch (arg.metric)
    case 'rmse'
        %RMSE [default]
        e = sqrt(middle((x-y).^2));
    case 'pct_rmse'
        %PCT Change
        e = 100 * sqrt(middle(((x-y)./x).^2));
    case 'nrmse'
        %normalized rmse
        ymax = nanmax(y);
        ymin = nanmin(y);
        e = rmse(x, y, '-usemedian', arg.usemedian) / (ymax - ymin);
    case 'cv_rmse'
        % cv rmse
        e = rmse(x,y, '-usemedian', arg.usemedian) / middle(y);
    otherwise
        error('Unknown metric: %s', arg.metric);
end
