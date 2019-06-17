function evalClassify(varargin)
% pnames = {'-test_gct','-test_target','-out','-model'};

toolName = mfilename ; 
pnames = {'-test_gct','-test_target','-out','-model'};
dflts = {'','',pwd,''};

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

% otherwkdir = mkworkfolder(arg.out,toolName); 
% fprintf('Saving analysis to %s\n',otherwkdir); 
% fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
% print_tool_params2(toolName,fid,arg); 
% fclose(fid); 

load(arg.model); 

[ge,gn,~,sid] = parse_gct(arg.test_gct);
T = parse_cls(arg.test_target); 
% T = strcmp('Success',T); 

[~,L] = intersect_ord(gn,landmarks); 

if ~isempty(setdiff(landmarks,gn))
    disp(setdiff(landmarks,gn))
    error('Some landmarks not found'); 
end

yhat = glmval(b,zscore(ge(L,:)'),'logit'); 

figure(findNewHandle) ;

[~,ix] = sort(T); 
stairs(yhat(ix),'LineWidth',1.5); 
hold on ; 
plot(yhat(ix),'r.')
append_sid_cls(T(ix),gcf,'x_axis'); 
ylabel('Probability of Success'); 
set(gca,'XTick',1:length(ix),'XTickLabel',sid(ix)); 
rotateticklabel(gca); 

figure(findNewHandle); 
plotconfusion(strcmp('Success',T)',yhat'); 
% save(fullfile(otherwkdir,[pullname(arg.test_gct),'_predictions']),'yhat',...
%     'sid'); 