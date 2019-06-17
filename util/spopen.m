function [okay,mp_prior_size] = spopen(num_labs) 
    
if nargin == 0
    num_labs = 12;
end

try
    if matlabpool('size') == 0 
        mp_prior_size = 0; 
        if nargin == 0
            matlabpool open ; 
        else
            eval(['matlabpool open ',num2str(num_labs),';']);
        end
        
    elseif matlabpool('size') ~= num_labs
        mp_prior_size = matlabpool('size'); 
        spclose ; 
        spopen(num_labs); 
        
    else
        mp_prior_size = matlabpool('size'); 
    end
    okay = true; 
catch em
    disp(em); 
    fprintf(1,'%s\n','Parallel toolbox not installed'); 
    okay = false; 
end
