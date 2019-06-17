function [stat,pvalue] = copy_associate(hmm_struct,expected_prior) 

% num_states = length(hmm_struct.statenames) ; 

stat = zeros(1,3); 
state_order = {'GAIN','LOSS','STABLE'}; 

N = 200; 
for i = 1 : 3
    idx = strcmp(state_order{i},hmm_struct.statenames); 
    if sum(idx)==0
        continue
    end
    expected = round(expected_prior*(N*( hmm_struct.state_prior(idx)/...
        sum(hmm_struct.state_prior)) ) ) ; 
    obs = round(hmm_struct.emis(idx,:)*(N*( hmm_struct.state_prior(idx)/...
        sum(hmm_struct.state_prior)) ) ); 
    stat(i) = sum( (obs(:)-expected(:)).^2 ./expected(:) ); 
end

stat(stat==Inf) = 0; 
stat(stat==NaN) = 0; 
pvalue = 1- chi2cdf(stat,2); 