function dir_struct = getdirs(pathname)

if nargin == 0
    pathname = pwd ; 
end

dir_struct = dir(pathname); 
flag = zeros(length(dir_struct),1); 

for i = 1 : length(dir_struct)
    if ~dir_struct(i).isdir || ismember(dir_struct(i).name,{'.','..','.DS_Store'})
        flag(i) = 1; 
        continue
    end
end

dir_struct(logical(flag))=[];
