function obj = parse_params(fname)
% PARSE_PARAMS Parse parameters file from function call
% 
% Author: Brian Geier, Broad 2010

fid = fopen(fname,'r'); % Check number of lines
num_lines = 0; 
while 1 
    if ~ischar(fgetl(fid)), break, end
    num_lines = num_lines + 1; 
end
tline = cell(num_lines,1); 
frewind(fid); 

i = 1; 
% Read lines
while 1
    a = fgetl(fid); 
    if ~ischar(a), break, end
    tline{i} = a; 
    i = i + 1; 
end
fclose(fid);

[mfile,~] = strread(tline{1},'%s%s','delimiter',':');
obj.fn_name = mfile{:}; 
for i = 2: num_lines
    [param,param_val] = strread(tline{i},'%s%s','delimiter',' '); 
    param{1}(param{1}==':') = [];
    obj.(param{1}) = param_val; 
%     eval(['obj.',param{:},' = ','''',param_val{:},'''',';']); 
end
