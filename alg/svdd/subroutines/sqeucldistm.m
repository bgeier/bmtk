function D = sqeucldistm(A,B)
%SQEUCLDISTM Square Euclidean distance matrix
%
%        D = SQEUCLDISTM(A,B)
%
% A specialized function for computing the squared Euclidean
% distance D between datasets A and B. This is mainly for
% computational speed, so it is light-weight, without any checking.
% Normal users will probably use myproxm.
%
% Mainly for internal use.
%
% see also: myproxm

% Copyright: D.M.J. Tax, davidt@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

nra = size(A,1);
nrb = size(B,1);
dA = sum(A.*A,2);
dB = sum(B.*B,2);
D = repmat(dA,1,nrb) + repmat(dB',nra,1) -2*A*B';
D(D<0) = 0;

return

