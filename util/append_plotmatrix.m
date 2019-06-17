function append_plotmatrix(AX,cellarray)

if size(AX,1) ~= length(cellarray)
    error('inconsistent dimensions')
end

for i = 1 : length(cellarray)
    ylabel(AX(i,1),cellarray{i}); 
    xlabel(AX(length(cellarray),i),cellarray{i})
end