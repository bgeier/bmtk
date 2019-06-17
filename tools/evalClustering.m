function evalClustering(varargin)
% pnames = {'-gct','-cls','-out','-grp','-covariate','-k'}; 

toolName = mfilename ; 
pnames = {'-gct','-cls','-out','-grp','-covariate','-k','-drop'}; 
dflts = {'','',pwd,'','','',''};

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 

spopen ; 

[ge,gn,gd,sid] = parse_gct(arg.gct);
cl = parse_cls(arg.cls); 

if ~isempty(arg.drop) 
    [~,keep] = setdiff(sid,parse_grp(arg.drop)); 
    ge = ge(:,keep); 
    cl = cl(keep); 
    sid = sid(keep); 
else
    keep = 1:length(sid); 
end

if ~isempty(arg.covariate)
    covariate = str2double(parse_grp(arg.covariate));
    if length(covariate) ~= length(sid)
        error('covariate is not consistent with sid'); 
    end
    covariate = covariate(keep); 
else
    covariate = rand(length(sid),1); 
end

if isempty(arg.k)
    k = 2:12;
else
    k = str2double(arg.k); 
end

[~,landmarks] = intersect_ord(gn,parse_grp(arg.grp)); 
if isempty(landmarks)
    error('landmarks not found...'); 
end
if isempty(arg.grp)
    [~,ix] = sort(cv(ge),'descend'); 
    landmarks = ix(1:1000); 
end

if length(k) == 1
    [m,t] = conclust(ge(landmarks,:)',k,true); 
    h = findNewHandle(); 
    figure(h); 
else
    [m,t,h,k] = conclust(ge(landmarks,:)',k,true); 

    set(h,'Name','ClusterSizeSearch'); 
    figure
end

hold on 
colors = mkcolorspec(k); 
l_h = cellstr([repmat('cluster-',[k,1]),num2str((1:k)')]) ; 
flag = zeros(k,1); 
boots = zeros(10000,k); 
y = zeros(1,k); 
e = zeros(1,k); 
for i = 1 : k
    if sum(t==i) < 5
        flag(i) = 1; 
        continue
    end
    boots(:,i) = bootstrp(10000,@nanmean,covariate(t==i),'options',statset('UseParallel','always')); 
    [n,x] = hist(boots(:,i),30); 
    bar(x,n,1,colors{i})
    y(i) = nanmean(covariate(t==i)); 
    e(i) = nanstd(covariate(t==i)); 
end
l_h(logical(flag)) = [];
legend(l_h); 
xlabel('Asymptotic Mean of covariate'); 
ylabel('Count'); 
set(gcf,'Name','covariate_behavior'); 

[group,drop] = dropSingletons(t); 
X = covariate ; 
X(drop) = [];
anova1(X(~isnan(X)),group(~isnan(X))); 
close

figure
errorbar(y,e,'xr')
xlabel('Cluster')
ylabel('Observed Covariate Mean'); 
set(gcf,'Name','errorBar');
figure
boxplot(boots)
xlabel('Asymptotic Distribution of Mean in Discovered Cluster'); 
set(gcf,'Name','BootBoxplot') ; 

[~,ix] = sort(t); 
figure

imagesc(1-m(ix,ix))
colormap bone
title(['Consensus Clustering with k=',num2str(k)]); 
append_cluster_membership(t(ix),gcf,'x_axis'); 
append_cluster_membership(t(ix),gcf,'y_axis'); 
set(gca,'YTick',1:length(cl),'YTickLabel',sid(ix),...
    'XTick',1:length(cl),'XTickLabel',cl(ix)); 
rotateticklabel(gca); 
% grid on 
set(gcf,'Name',['conclust_k=',num2str(k)]); 

num_groups = length(unique(cl)); 
% groups = unique(cl); 
if num_groups == 2
%     [~,tstat] = mattest(ge(landmarks,strcmp(groups{1},cl)),...
%         ge(landmarks,strcmp(groups{2},cl))); 
    [~,weight] = relieff_parallel(ge(landmarks,:)',cl,10); 
    [~,ix] = sort(weight,'descend'); 
    b = glmfit(ge(landmarks(ix(1)),:)',strcmp('Success',cl),...
        'binomial','link','logit'); 
    yfit = glmval(b,ge(landmarks(ix(1)),:)','logit');
    figure
    plot(ge(landmarks(ix(1)),:),yfit,'.','MarkerSize',12)
    set(gcf,'Name','LogisticRegressionFit'); 
    set(gca,'FontSize',12); 
    xlabel(['Gene-Expression of ',gn(landmarks(ix(1)))])
    ylabel('Probability of Success')
elseif num_groups < 6
    [~,weight] = relieff_parallel(ge(landmarks,:)',cl,10); 
    [~,ix] = sort(weight,'descend'); 
else
    ix = randperm(length(landmarks)); 
end


figure
parallelcoords(ge(landmarks(ix),:)','standardize','on','quantile',0.15,...
    'Group',cl,'Labels',gd(landmarks(ix)),...
    'LineWidth',1.5,'MarkerSize',12)
rotateticklabel(gca); 
set(gcf,'Name','parallelcoordsView'); 

z = zscore(ge(landmarks(ix(1:3)),:)'); 
names = gn(landmarks(ix(1:3))); 
figure
[~,ix] = sort(cl); 
bar(z(ix,:))

append_sid_cls(cl(ix),gcf,'x_axis'); 
set(gca,'XTick',1:length(ix),'XTickLabel',sid(ix)) ; 
rotateticklabel(gca); 
set(gcf,'Name','TopMarkers'); 
legend(names); 

num_handles = findNewHandle ;

cg = clustergram(ge(landmarks,:),'ColumnLabels',cl,'RowLabels',gn(landmarks),...
    'RowPDist','correlation','ColumnPDist','correlation','linkage',...
    'complete'); 
addTitle(cg,[dashit(pullname(arg.grp)),' heat map']) ;

plot(cg)
set(gcf,'Name','ClusteredHeatMap'); 


for i = h : num_handles
    figure(i)
    orient landscape
    try 
        saveas(gcf,fullfile(otherwkdir,get(gcf,'Name')),'pdf'); 
        saveas(gcf,fullfile(otherwkdir,get(gcf,'Name')),'png');
        close(i) ;
    catch em
        disp(em)
        close(i) ;
        continue
    end
   
end

fid = fopen(fullfile(otherwkdir,'evalClusteringStats.txt'),'w'); 
print_tool_params2(toolName,fid,arg); 
fprintf(fid,'%s\n','%%Begin Data'); 
num_samples = size(ge,2); 
fprintf(fid,'%s\t%s\t%s\t%s\n','Sample','Class','Cluster','Covariate'); 
for i = 1 : num_samples
    fprintf(fid,'%s\t%s\t%s\t%s\n',sid{i},cl{i},num2str(t(i)),num2str(covariate(i))); 
end
fclose(fid); 

end


function [group,drop] = dropSingletons(t)
% Require at least 4 observations per cluster - drop all other clusters

tbl = tabulate(t); 
drop_lbs = tbl(tbl(:,2) < 4,1); 
% t(tbl(:,2) < 4) = [];
drop = [];
for i = 1 : length(drop_lbs)
    drop = [drop ; find(t==drop_lbs(i)) ]; 
    t(t==drop_lbs(i))  = [];
end
group = t ;
end

