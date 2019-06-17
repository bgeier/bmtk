function [pfp,pval] = RankProductSelection(X,Y,num_perm)

% fold_change = mean(X,2) - mean(Y,2); 
num_genes = size(X,1); 
RP.up.observed = RankProd(X,Y,false) ;
ranks.up.observed = sorted_ranks(RP.up.observed); 
RP.dn.observed = RankProd(X,Y,true); 
ranks.dn.observed = sorted_ranks(RP.dn.observed); 

RP.up.perm = nan*ones(num_genes,num_perm); 
RP.dn.perm = nan*ones(num_genes,num_perm); 
print_str('Starting premutations...'); 
h = waitbar(0,'Running permutations...'); 
for p = 1 : num_perm
    tmp = permuteData(data1,data2); 
    RP.up.perm(:,p) = getfield(RankProd(tmp.data1,tmp.data2,false),...
        'rank_prod'); 
    RP.dn.perm(:,p) = getfield(RankProd(tmp.data1,tmp.data2,true),...
        'rank_prod');
    waitbar(p/num_perms,h) ;
end
close(h); 




end


function RP = RankProd(X,Y,rev_sorting)


num_genes = size(X,1); 
if rev_sorting
    data1 = Y; 
    data2 = X; 
else
    data1 = X; 
    data2 = Y; 
end

k1 = size(data1,2); 
k2 = size(data2,2); 

num_rep = k1*k2; 

rep.data = nan*ones(num_genes,num_rep); 

for k = 1 : k1
    tmp = ((k-1)*k2 + 1):(k*k2) ; 
    rep.data(:,tmp) = data1(:,k) - data2; 
end

rep.ranks = sorted_ranks(rep.data,1); 
rep.ranks(isnan(rep.data))= 1; 
num_ranks = sum(isnan(rep.data),2); 
num_col = size(rep.ranks,2); 
if (num_col > 50 && num_gene > 2000) || num_col > 100
    rank_prod_tmp = rep.ranks.^(1/num_ranks); 
    rank_prod = prod(rank_prod_tmp,2); 
else
    rank_prod = prod(rep.ranks,2).^(1/num_ranks); 
end

rank_prod(num_ranks==0) = nan; 

RP.rank_prod = rank_prod; 
RP.rank_all = rep.ranks; 



end

function NewData = permuteData(data1,data2)

[num_genes,k1] = size(data1,2); 
NewData.data1 = nan*ones(num_genes,k1); 
[~,tmp] = sort(rand(num_genes,k1),1); 
for k = 1 : k1
    NewData.data1(:,k) = data1(tmp(:,k),k); 
end
k2 = size(data2,2); 
NewData.data2 = nan*ones(num_genes,k2); 
[~,tmp] = sort(rand(num_genes,k2),1); 
for k = 1 : k2
    NewData.data2(:,k) = data2(tmp(:,k),k); 
end

end