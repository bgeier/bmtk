function [spec,width] = mkcolorspec(num_lines,marker_type)

colors = {'blue','green','red','cyan','magenta','yellow','black'};

if nargin == 1
    marker_type = 'dot'; 
end
% will give 14 unique combinations

if num_lines > 14
    
    spec = repmat(colors,[1,ceil(num_lines/7)]); 
    width = NaN; 
    
else

    if num_lines <= length(colors)
        switch marker_type
            case 'line'
                width = ones(num_lines,1); 
                
            case 'dot'
                width = cell(num_lines,1); 
                width(:) = {'.'}; 
        end
        
        spec = colors(1:num_lines); 
    else
        spec = cell(num_lines,1); 
        
        spec(1:length(colors)) = colors ; 
        spec(length(colors)+1:end) = colors(1:(num_lines-length(colors)));  
        switch marker_type
            case 'line'
                width = ones(num_lines,1); 
                width(length(colors)+1:end) = 2; 
            case 'dot'
                width = cell(num_lines,1); 
                width(length(colors)+1:end) = {'*'}; 
                width(1:length(colors)) = {'.'};
        end
    end
    
end