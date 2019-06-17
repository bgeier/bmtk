function merge_tables(files,fname,variant_type,out)

if nargin == 3
    out = pwd ; 
end
if nargin < 2
    error('')
end

% files.name = fullfile(pathname,filename); 
input = struct('name','','key','','idx',''); 
keys = [];
switch variant_type
    case 'snp'
        idx_string = [1,0,0,1,1,1,0,0,0,0,1,1,1,1,1,1,1]; 
    case 'indel'
        
        idx_string = [1 0 0 1 1 1 0 0 0 0 1 1 1 1 1 ]; 
        
end

for i = 1 : length(files)
    print_str(['PARSEKEY : : ',pullname(files(i).name)]); 
    input(i).name = pullname(files(i).name); 
    data = parse_variant(files(i).name,variant_type); 
    header = fieldnames(data); 
    [input(i).key,input(i).idx] = mkvariantkey(data,variant_type); 
    keys = [keys ; input(i).key]; 
    clear data ; 
end

union_keys = unique_ord(keys); 

num_lines = length(union_keys); 
% Create indicator matrix for samples with variant
idx = zeros(num_lines,length(files)); 
for i = 1 : length(files)
    [~,L] = intersect_ord(union_keys,input(i).key); 
    idx(L,i) = 1; 
end

fid = fopen(fullfile(out,fname),'w'); 
for i = 1 : length(header)
    fprintf(fid,'%s\t',header{i}); 
end
for i = 1 : length(files)-1
    fprintf(fid,'%s\t',input(i).name); 
end
fprintf(fid,'%s\n',input(i+1).name); 

lines_written = 0; 
written = []; 
print_str(['Writing ',num2str(num_lines),' to file']); 
for i = 1 : length(files)
    [~,lines_found] = intersect_ord(input(i).key,union_keys); 
    data = parse_variant(files(i).name,variant_type); 
    [~,ix] = setdiff(input(i).key(lines_found),written); 
%     lines_found = lines_found(idx); 
    trac = input(i).idx(lines_found(ix)); 
    
    h = waitbar(0,'Writing lines...'); 
    [~,ref] = intersect_ord(union_keys,input(i).key(lines_found(ix))); 
%     ref = ref(ix); 
    
    N = length(trac);
    print_str(['Writing ',num2str(N),' lines..']); 
    for k = 1 : N
        for j = 1 : length(header)
            if idx_string(j)
%                 try
                t = char(getfield(data,{1},header{j},...
                    {trac(k)}));
%                 catch
%                     print_str(['i=',num2str(i),'k=',num2str(k),...
%                         '
                if isempty(t)
                    fprintf(fid,'%s\t','novel'); 
                else
                    fprintf(fid,'%s\t',t); 
                end
            else
                fprintf(fid,'%f\t',getfield(data,{1},header{j},...
                    {trac(k)}));
            end
        end
        for j = 1 : length(files)-1
            if idx(ref(k),j) 
                fprintf(fid,'%s\t','yes');
            else
                fprintf(fid,'%s\t','no');
            end
        end
        if idx(ref(k),j+1) 
            fprintf(fid,'%s\n','yes');
        else
            fprintf(fid,'%s\n','no');
        end
        waitbar(k/N,h); 
    end
    close(h); 
    
    lines_written = lines_written + N; 
    written = [written ; input(i).key(lines_found)] ; 
    if lines_written >= num_lines
        break
    end

end
fclose(fid); 