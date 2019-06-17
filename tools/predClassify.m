function predClassify(varargin)

toolName = mfilename ; 
pnames = {'-test_gct','-test_target','-landmarks','-model'};
dflts = {'','','',''};

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

% otherwkdir = mkworkfolder(arg.out,toolName); 
% fprintf('Saving analysis to %s\n',otherwkdir); 
% fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
% print_tool_params2(toolName,fid,arg); 
% fclose(fid); 

% spopen ; 

[ge,gn] = parse_gct(arg.test_gct);
T = parse_cls(arg.test_target); %Either Success or Failure

load(arg.model); 

[~,landmarks] = intersect_ord(gn,parse_grp(arg.landmarks)); 

yhat = svmclassify(svmfit,ge(landmarks,:)'); 

% yhat = sim(net,(ge(landmarks,:)')'); 

plotconfusion(strcmp('Success',T)',strcmp('Success',yhat)'); 
% plotroc(strcmp('Success',T)',strcmp('Success',yhat)');