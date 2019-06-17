function D = distm(A,B)

[ma,ka] = size(A);
[mb,kb] = size(B);

if (ka ~= kb)
    error('Feature sizes should be equal')
end

% The order of operations below is good for the accuracy.
D = ones(ma,1)*sum(B'.*B',1);
D = D + sum(A.*A,2)*ones(1,mb);
D = D - 2 .* (+A)*(+B)';

J = find(D<0);                  % Check for a numerical inaccuracy. 
D(J) = zeros(size(J));          % D should be nonnegative.

if ((nargin < 2) && (ma == mb)) % take care of symmetric distance matrix
    D = (D + D')/2;              
    D(1:(ma+1):ma*ma) = zeros(1,ma);
end