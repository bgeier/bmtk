function [B,cnts,I,J] = uniqc(labels)

[B,I,J] = unique_ord(labels); 
cnts = zeros(size(B)); 
parfor i = 1 : length(B)
    cnts(i) = sum(strcmp(B{i},labels)); 
end