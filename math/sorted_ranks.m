function ranks = sorted_ranks(y,DIM,MODE)

if nargin == 1
    [~,I] = sort(y); 
    ranks = 1:length(y); 
    ranks(I) = 1:length(y); 
elseif nargin == 2
    [~,I] = sort(y,DIM); 
    ranks = 1:length(y); 
    ranks(I) = 1:length(y); 
else
    [~,I] = sort(y,DIM,MODE); 
    ranks = 1:length(y); 
    ranks(I) = 1:length(y); 
end