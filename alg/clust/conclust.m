function [M,T,h,num_clusters,y,Z,mk] = conclust(D,num_clusters,buildFinal,varargin)
% CONCLUST  Perform Consensus Clustering
%   CONCLUST(D,num_clusters) will perform consesnsus clustering on the data
%   set D. Currently, the implementation supports unsupervised or
%   supervised hierarchical clustering. Many cluster settings are hard
%   coded. The algorithm is computationally expensive and should be
%   executed on a multi-core machine with the parallel computing toolbox. 
%   Inputs: 
%       D : an n by p matrix of data
%       num_clusters : the number of clusters to partition D. This input
%       parameter can be a scalar or a vector of potential sizes, which are
%       evaluated in an automatic fashion. 
%   Outputs: 
%       M : The consensus matrix. Each element is a measure of how often or
%       likely a pair of observations travel togeather given sampling
%       instability. In a perfect case, this is a matrix of 1's and 0's.
%       T : The cluster assigment when using M as a similiarity matrix
%       mk : The consensus measure for each partition
%       Z : The linkage for the hierarchical cluster tree using the average
%       linkage algorithm. 
%       num_clusters : If the input 'num_clusters' was scalar then this
%       parameter is not necessary. If the input was a vector of potential
%       partitions then the output is the pick. 
% 
% Citation: S. Monti ET AL. Consensus Clustering: A Resampling-Based Method
% for Class Discovery and Visualization of Gene Expression Microarray Data.
% Machine Learning, 52, 91-118, 2003. 
% 
% Author: Brian Geier

toolName = mfilename ; 
pnames = {'-method','-num_permutations','-pct'};
dflts = {'hclust',800,0.9};
% arg.method = method; 
arg = getargs2(pnames,dflts,varargin{:}); 
print_tool_params2(toolName,1,arg); 


start = tic; 
% isParallel = spopen ; 

% if ~isParallel
%   print_str(['Sequential exceuction will take a while for ' ...
%                     'large sets'])
% end


if nargin == 2
    buildFinal = 1 ;
end

if length(num_clusters) > 1
    auc = zeros(1,length(num_clusters)); 
    deltak = zeros(size(auc)); 

    for i = 1 : length(num_clusters) % adaptive cluster selection 
        M = conclust(D,num_clusters(i),buildFinal,'-method',arg.method,...
            '-num_permutations',arg.num_permutations,'-pct',arg.pct); 
        if length(unique(M(:))) == 2
            auc(i) = sum(M(:)==0)/length(M(:)); 
        else
            [f,x] = ecdf(M(:)); 
            auc(i) = AUC(x,f); 
        end
       
        if i > 1
            deltak(i) = (auc(i) - auc(i-1))/auc(i-1); 
            if (abs(deltak(i-1) - deltak(i)) < 0.05) && (deltak(i-1) > deltak(i))
                print_str('Stoping cluster size search...')
                pick = i -1;  
                break
            end
        else 
            deltak(i) = auc(i); 
        end
        
    end
    if ~exist('pick','var')
        pick = i;  
        print_str('Cluster search performance not met'); 
    end
    h = findNewHandle(); 
    figure(h); 
    plot(num_clusters,deltak,'.','MarkerSize',12); 
    xlabel('Number of Clusters')
    ylabel('Gain in Performance')
    title('Performance Gain as a function of partitions')
%     [~,pick] = min(abs(diff(deltak))); 
    hold on ; plot(num_clusters(pick),deltak(pick),'ro','MarkerSize',12)
    num_clusters = num_clusters(pick); 
end

[n,p] = size(D); 
B = arg.num_permutations ; 
pct = arg.pct; % subsampling proportion, i.e. 80% random sample with replacement

fprintf(1,'%s\n',horzcat(arg.method,' Consensus Clustering with data params')); 
fprintf(1,'%s\n',horzcat('Subsample Percentage: ',num2str(pct*100))); 
fprintf(1,'%s\n',horzcat('Cluster Iterations: ',num2str(B))); 
fprintf(1,'%s\n',horzcat('Samples: ',num2str(n))); 
fprintf(1,'%s\n',horzcat('Features: ',num2str(p))); 

connectivity_matrices = zeros(size(D,1),size(D,1),B) ;
presence = zeros(size(connectivity_matrices)); 
% if isParallel
  T = codistributed.zeros(floor(size(D,1)*pct),B); 
% else
%   T = zeros(floor(size(D,1)*pct),B);
% end

[~,ix] = sort(rand(size(D,1),B)); 

switch arg.method
    case 'cclust'
        parfor lab = 1 : B % computationally expensive
            Y = pdist(D(ix(1:floor(size(D,1)*pct),lab),:),'correlation'); 
%             Y = pdist(D(ix(1:floor(size(D,1)*pct),lab),:)); 
            Z = linkage(Y,'complete'); 
            T(:,lab) = cluster(Z,'maxclust',num_clusters); 
        end
    case 'hclust'
        parfor lab = 1 : B % computationally expensive
            Y = pdist(D(ix(1:floor(size(D,1)*pct),lab),:));%,'correlation'); 
%             Y = pdist(D(ix(1:floor(size(D,1)*pct),lab),:)); 
            Z = linkage(Y,'complete'); 
            T(:,lab) = cluster(Z,'maxclust',num_clusters); 
        end
    case 'nnmf'
        print_str('Running nnmf'); 
        parfor lab = 1 : B % computationally expensive
            
            
            [~,H] = nnmf(D(ix(1:floor(size(D,1)*pct),lab),:)',num_clusters,...
                'replicates',10); 
            
            [~,T(:,lab)] = max(H); 
            
        end
    case 'kmeans'

        parfor lab = 1 : B
            T(:,lab) = kmeans(D(ix(1:floor(size(D,1)*pct),lab),:),...
                num_clusters,...
                'replicates',5); 
        end
    case 'gmm'
%         fprintf(1,'%s\n','Sphereing and getting principal components'); 
%         D = zscore(D)*pcacov(cov(zscore(D))); 
%         D = D(:,1:50); 
        fprintf(1,'%s\n','Running Model Based Clustering Consensus'); 
        parfor lab = 1 : B
            obj = gmdistribution.fit(D(ix(1:floor(size(D,1)*pct),lab),:),...
                num_clusters,'CovType','full','SharedCov',false,...
                'Replicates',10,'options',statset('MaxIter',1000));  
            p = posterior(obj,D(ix(1:floor(size(D,1)*pct),lab),:)); 
            [~,T(:,lab)] = max(p,[],2); 
        end
    otherwise
        error(horzcat(arg.method,' is unsupported')); 
end


h_wb = waitbar(0,'Gathering Consensus Metrics...'); 
% if isParallel
  T = gather(T); 
% end

idx = ix(1:floor(n*pct),:); 
for lab = 1 : B
    stepT = (T(:,lab)); 
    presence(idx(:,lab),idx(:,lab),lab) = 1;
    connectivity_matrices(idx(:,lab),idx(:,lab),lab) = ...
        repmat(stepT(:),1,length(idx(:,lab))) == repmat(stepT(:)',length(idx(:,lab)),1); 
    waitbar(lab/B,h_wb)
end
close(h_wb); 

M = sum( connectivity_matrices, 3)./sum( presence, 3) ; 

if buildFinal

    print_str('Performing Clustering with Consensus Matrix'); 
    Z = linkage(squareform(1-M),'complete'); 
%     [H,T] = dendrogram(Z,'colorthreshold','default'); 
%     set(H,'LineWidth',1.5); 
    T = cluster(Z,'maxclust',num_clusters); 
    y = cmdscale(squareform(1-M)); 
    
    mk = getmk(M,T); 
    
else
    Z = NaN; 
    T = NaN; 
    mk = NaN ;
end

fprintf(1,'%s\n',horzcat('Consensus clustering took ',num2str(toc(start)/60),...
    ' minutes')); 
end