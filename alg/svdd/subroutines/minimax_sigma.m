% coeff = pcacov(cov(x)); 
% pcomp = x*coeff(:,1:2); 
%%
N = 500; 
% target = randperm(length(data) );
% temp = zeros(length(data),1) ;
% matlabpool open ;
% training = data(~logical(truth),:); % 1 - target, 0 - not target
% training = pcomp(~logical(target),:); 
% ix = randperm(length(training) ) ; 
% training = training(ix(1:N),:); 
iters = 3; 
ix = reshape(randsample(1:length(training),N*iters,true),[N iters]); 
% a = training(ix,:); 
% sigma_val = [1:2:14,20];
sigma_val = 1:10; 
% sigma_val = 0.1:.05:0.8; 
fracrej = [.01 .99]; 
% [bootstat,bootsam] = bootstrp(1000,@(x) det(cov(x)),a);
% clear bootsam
% sigma_val = det(cov(a)); 
% sigma_val = 500; %(quantile(bootstat,.01)); 
% clear bootstat

signlab = ones(N,1);
nrtar = length(find(signlab==1));
nrout = length(find(signlab==-1));
warning off; % we could get divide by zero, but that is ok.
C(1) = 1/(nrtar*fracrej(1));
C(2) = 1/(nrout*fracrej(2));
warning on;

% sigma_val = bandwith of kernel, +a is positive rep. of signal - cols are
% signals,

warning off; 

%%
tic
num_sv = zeros(iters,length(sigma_val));
for j = 1 : iters
    a = training(ix(:,j),:); 
    fprintf(1,'%s\n',horzcat('Running Iteration ',num2str(j))); 
    h = waitbar(0,'Running SVDD...'); 
    for i = 1 : length(sigma_val)
        [alf,R2,Dx,J] = svdd_optrbf(sigma_val(i),+a,signlab,C);
        SVx = +a(J,:);
        alf = alf(J);
        num_sv(j,i) = size(SVx,1); 
        waitbar(i/length(sigma_val),h); 
    end
    close(h); 
end
toc
warning on ; 
% figure ; hold on ; grid on ;
% c = 'rgb';
% for j = 1 : 3
figure,   plot(sigma_val,num_sv'/N)
grid on ; 

% matlabpool close ; 
