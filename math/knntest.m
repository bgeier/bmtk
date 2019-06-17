function output = knntest(varargin)

toolName = mfilename ; 
pnames = {'-train_gct','-train_target','-test_gct','-test_target',...
    '-out','-landmarks','-k','-drop','-model'};
dflts = {'','','','',pwd,'',5,'','knn'};

arg = getargs2(pnames,dflts,varargin{:});
print_tool_params2(toolName,1,arg); 

% otherwkdir = mkworkfolder(arg.out,toolName); 
% fprintf('Saving analysis to %s\n',otherwkdir); 
% fid = fopen(fullfile(otherwkdir,sprintf('%s_params.txt',toolName)),'wt'); 
% print_tool_params2(toolName,fid,arg); 
% fclose(fid); 

[ge.train,gn.train,gd.train,sid.train] = parse_gct(arg.train_gct); 

[~,L] = intersect_ord(gn.train,parse_grp(arg.landmarks)); 

ge.train = ge.train(L,:); 
gn.train = gn.train(L); 
gd.train = gd.train(L); 

[ge.test,gn.test,gd.test,sid.test] = parse_gct(arg.test_gct); 

[~,L] = intersect_ord(gn.test,parse_grp(arg.landmarks)); 

ge.test = ge.test(L,:); 
gn.test = gn.test(L); 
gd.test = gd.test(L); 

cl.train = parse_cls(arg.train_target); 

drop = ~(strcmp('Resistant',cl.train) | strcmp('Sensitive',cl.train)) ; 
cl.train(drop) = [];
sid.train(drop) = [];
ge.train(:,drop) = [];

cl.train(strcmp('Resistant',cl.train)) = {'Fail'}; 
cl.train(strcmp('Sensitive',cl.train)) = {'Success'};

if ~isempty(arg.drop)
    [~,drop] = intersect_ord(sid.test,parse_grp(arg.drop)); 
    ge.test(:,drop) = [];
    sid.test(drop) = [];
    output.drop = drop; 
end

[~,i,j] = intersect_ord(gn.test,gn.train); 

B = 1000; 
pp = zeros(length(sid.test),2); 
% X.train = double(zscore(ge.train(j,:)')); 
% X.test = double(zscore(ge.test(i,:)')); 

[X.train,ps] = processpca(mapstd(ge.train(j,:))); 
X.test = processpca(mapstd(ge.test(i,:)),ps); 
X.train = X.train'; 
X.test = X.test'; 

X.train(:,4:end) = [];
X.test(:,4:end) = [];

h = waitbar(0,'Computing posterior probabilities..'); 

switch arg.model
    case 'knn'
        for jj = 1 : length(sid.test)
            idx = reshape(randsample(1:length(sid.train),B*length(sid.train),true),...
                length(sid.train),B);
            parfor ii = 1 : B
%                 idx = randperm(length(sid.train)); 
%                 calls(ii) = knnclassify(X.test(jj,:),X.train(idx(1:end-1),:),...
%                     cl.train(idx(1:end-1)),arg.k);
                if length(unique(cl.train(idx(:,ii)))) == 2
                    calls(ii) = knnclassify(X.test(jj,:),X.train(idx(:,ii),:),...
                        cl.train(idx(:,ii)),arg.k);
                    
                else 
                    calls(ii) = {'foo'}; 
                end
            end
            pp(jj,1) = sum(strcmp('Success',calls))/sum(~strcmp('foo',calls)); 
            pp(jj,2) = sum(strcmp('Fail',calls))/sum(~strcmp('foo',calls)); 
            waitbar(jj/length(sid.test),h); 
        end
    case 'svm'
        for jj = 1 : length(sid.test)
            idx = reshape(randsample(1:length(sid.train),B*length(sid.train),true),...
                length(sid.train),B);
            parfor ii = 1 : B
                if length(unique(cl.train(idx(:,ii)))) == 2
                    calls(ii) = svmclassify(svmtrain(X.train(idx(:,ii),:),...
                        cl.train(idx(:,ii)),'kernel_function','rbf')...
                        ,X.test(jj,:)); 
                else
                    calls(ii) = {'foo'}; 
                end
            end
            pp(jj,1) = sum(strcmp('Success',calls))/sum(~strcmp('foo',calls)); 
            pp(jj,2) = sum(strcmp('Fail',calls))/sum(~strcmp('foo',calls)); 
            waitbar(jj/length(sid.test),h); 
        end
end
        
close(h); 
classes = {'Success','Fail'}; 
thresh = .55; 
prediction = cell(size(sid.test)); 
prediction(pp(:,1) > thresh) = {'Success'}; 
prediction(pp(:,2) > thresh) = {'Fail'}; 
prediction(~(pp(:,1) > thresh | pp(:,2) > thresh)) = {''}; 
output.pp = pp; 
output.classes = classes ; 

if ~isempty(arg.test_target)
    cl.test = parse_cls(arg.test_target); 

    if any(strcmp('Resistant',cl.test))
        drop = ~(strcmp('Resistant',cl.test) | strcmp('Sensitive',cl.test)) ; 
        cl.test(drop) = [];
        sid.test(drop) = [];
        ge.test(:,drop) = [];
    end

    cl.test(strcmp('Resistant',cl.test)) = {'Fail'}; 
    cl.test(strcmp('Sensitive',cl.test)) = {'Success'};

    plotroc(strcmp('Success',cl.test)',pp(:,1)','Success',strcmp('Fail',cl.test)',...
        pp(:,2)','Fail'); 

    output.perf = classperf(cl.test,prediction); 
end