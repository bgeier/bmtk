function str = dashit(str,rev)

if nargin == 1
    rev = 0; 
end
if ~rev
    if ~iscell(str)
        str(str=='_') = '-'; 
    else
        for i = 1 : length(str)
            str{i} = dashit(str{i}); 
        end
    end
else
    if ~iscell(str)
        str(str=='-') = '_'; 
    else
        for i = 1 : length(str)
            str{i} = dashit(str{i},rev); 
        end
    end
end