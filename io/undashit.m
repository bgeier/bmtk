function str = undashit(str)

if ~iscell(str)
    str(str=='-') = '_'; 
else
    for i = 1 : length(str)
        str{i} = undashit(str{i}); 
    end
end
