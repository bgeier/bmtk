function [pp,svdd_obs] = chkinput(x,svdd_null,w)

k = zeros(length(w.a),size(x,1)); 

parfor j = 1 : size(x,1)
    k(:,j) = evalsvdd(x(j,:),w); 
end

svdd_obs = w.offs + sum(k,1); 

[f,x] = ecdf(svdd_null); 
pp = zeros(length(svdd_obs),1); 

parfor i = 1 : length(svdd_obs)
    pp(i) = computePval(f,x,svdd_obs(i)); 
%     pp(i) = 1-f(min( x-svdd_obs(i) ) == x- svdd_obs(i)); 
end
pp = pp(:) ; svdd_obs = svdd_obs(:); 
end

function p = computePval(f,x,svdd_obs)

ix = find(min(abs(x-svdd_obs)) == abs(x-svdd_obs) ); 
p = f(ix(1)); 

end