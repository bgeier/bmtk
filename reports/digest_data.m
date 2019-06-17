function digest_data(varargin)

toolName = mfilename ; 
pnames = {'-data','-target','-feature_map','-out'}; 
dflts = {'','','',pwd};

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 

% read in csv file

x = parse_frame(arg.data); % assume tab delimited

% extract target using '-target' string identifier

y = x.(arg.target); 

feature_map = parse_frame(arg.feature_map); 
h = grab_header(arg.data); 
idx = strcmp(arg.target, fieldnames(x)); 

y = switch_feature(y,feature_map.type{strcmp(h{idx}, feature_map.feature)}); 

% x = rmfield(x, arg.target); 

% track whether categorical or continuous via feature_map txt

[~,ii,jj] = intersect_ord(grab_header(arg.data), feature_map.feature); 
f = fieldnames(x); 
f = f(ii); 

cat_flag = zeros(size(ii)); 
X = zeros(length(y), length(ii)); 
for i = 1 : length(ii)
    [X(:,i),cat_flag(i)] = switch_feature(x.(f{i}), feature_map.type{jj(i)}); 
end
    

% fit stack generalization

% extract variable importance via RF

% compute marginal importance via ttest or anova

% write out descriptive summary for all of the above

% generate vignettes of fit, etc
h = findNewHandle(); 
% assume binary for now...

[w,models,yhat,cv_error,model_errs] = ...
    stack_gen(X, y, find(cat_flag),1,0);

save(fullfile(otherwkdir,'scratch')); 

% print_stack_perf(fullfile(otherwkdir,'feature_summary.csv'),...
%     models, model_errs, cv_error,f)

% generate roc curve for each model
figure, hold on ; lh = cell(size(models)); 
c = mkcolorspec(length(lh)); model_name = cell(size(lh)); 
for i = 1 : length(models)
    [tpr,fpr] = roc(y(:)', yhat(:,i)'); 
    stairs(fpr,tpr,c{i},'linewidth',1.2); 
    lh{i} = [models(i).name,' CVE=',str2double(model_errs(i))]; 
    model_name{i} = models(i).name ; 
end 
[p,sn,ci_vals] = diff_profile(models(strcmp('rf',model_name)).mdl, cat_flag); 

output = struct; 
output.feature = f; 
output.signal2noise = sn; 
output.ttest2pval = p; 
output.lower_rf = ci_vals(:,1); 
output.upper_rf = ci_vals(:,2); 
fclose(print_frame(output,fopen(fullfile(otherwkdir,'feature_summary.csv'),'w'),',')); 

% overlay overall roc curve
[tpr,fpr] = roc(y(:)', glmval(w, yhat,'logit')'); 
stairs(fpr,tpr,'black--','linewidth',1.2); 
lh{end+1} = ['stack fit, CVE=',str2double(cv_error)]; 

legend(lh,'location','se'); 
set(h,'name','roc_curve'); 
orient landscape
axis square
for i = h : findNewHandle()-1
    saveas(i, fullfile(otherwkdir, 'roc_curve'),'pdf'); 
end

save(fullfile(otherwkdir,'scratch')); 

function f = grab_header(fname)
fid = fopen(fname); 
c = textscan(fgetl(fid),'%s','delimiter','\t'); 
f = c{1}; 
fclose(fid); 

function [p,t,ci_vals] = diff_profile(rf_fit,catFlag)

ci_vals = compute_rf_var_ci(rf_fit); 
p = NaN(size(rf_fit.X,2),1); 
t = NaN(size(p)); 
target = str2double(rf_fit.Y);
for i = 1 : length(p)
    if catFlag(i)
        [~,~,p(i)] = crosstab(target, rf_fit.X(:,i)); 
    else
        [~,p(i)] = ttest2(rf_fit.X(target==1, i), rf_fit.X(target==0,i)); 
        t(i) = get_s2n(rf_fit.X(target==1,i), rf_fit.X(target==0,i)); 
    end
end

function sn = get_s2n(x,y)

sn = (mean(x) - mean(y))./(std(x) + std(y)); 

function [y,isCat] = switch_feature(y, feature_type)

isCat = 0; 
switch feature_type
    case 'cont'
        y = str2double(y); 
    case 'binary'
        y = str2double(y); 
    case 'cat'
        y = grp2idx(y); 
        isCat = 1; 
    case 'time'
        y(strcmp('-',y)) = {'0:00:00'};
        y = datenum(y); 
end