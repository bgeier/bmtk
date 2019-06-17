function print_str(str,deltype)

if nargin == 0
    fprintf(1, '\n'); 
else
    if nargin ==1 
        deltype = '%s\n'; 
    end
    fprintf(1,deltype,str); 
end