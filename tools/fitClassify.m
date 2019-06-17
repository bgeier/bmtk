function fitClassify(varargin)

toolName = mfilename ; 
pnames = {'-gct','-target','-out','-landmarks'};
dflts = {'','',pwd,''};

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

otherwkdir = mkworkfolder(arg.out,toolName); 
fprintf('Saving analysis to %s\n',otherwkdir); 
fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
print_tool_params2(toolName,fid,arg); 
fclose(fid); 

% spopen ; 

[ge,gn,gd,sid] = parse_gct(arg.gct);
T = parse_cls(arg.target); %Either Success or Failure

T(strcmp('Resistant',T)) = {'Fail'}; 
T(strcmp('Sensitive',T)) = {'Success'}; 
y = strcmp('Success',T); 
landmarks = parse_grp(arg.landmarks); 
[~,L,found] = intersect_ord(gn,landmarks); 
if isempty(L)
    [~,L,found] = intersect_ord(gd,landmarks);
    if isempty(L)
        error('could not find landmarks'); 
    end
end

landmarks = landmarks(found); 

[b,~,stats] = glmfit(zscore(ge(L,:)'),y(:),'binomial',...
    'link','logit');
% inmodel = stats.p < 0.05; 
% 
% landmarks = landmarks(inmodel); 
% 
% print_str([num2str(length(landmarks)),' landmarks were used in the model']); 
% print_str([num2str(sum(inmodel)),' landmarks were significant in the model']); 
% 
% if ~all(inmodel)
%     [b,~,stats] = glmfit(zscore(ge(L(inmodel),:)'),y(:),'binomial',...
%         'link','logit'); 
% end
% 
% yhat = glmval(b,zscore(ge(L(inmodel),:)')); 
% 
% figure(findNewHandle) ;
% 
% [~,ix] = sort(T); 
% stairs(yhat(ix),'LineWidth',1.5); 
% append_sid_cls(T(ix),gcf,'x_axis'); 
% set(gca,'XTick',1:length(sid),'XTickLabel',sid(ix)); 
% rotateticklabel(gca); 
% ylabel('Probability of Success'); 

save(fullfile(otherwkdir,[pullname(arg.gct),'_with_',pullname(...
    arg.landmarks)]),'b','stats','landmarks'); 