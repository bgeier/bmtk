function [W,SVDD,ix] = svdd(X,sigma_val)
%[outlier_position,SVDD,num_sv] = svdd(X,truth,alpha_val,sigma_val)
% [W] = svdd(X,sigma_val)
tic

%  generate_test_parameters % control file
% training = X(~logical(truth),:); % 1 - target, 0 - not target
N = min(500,size(X,1)); 
training = double(X); 
ix = randsample(1:size(training,1),N,false); 
a = training(ix,:); 
% a = X;
fracrej = [.01 .99]; 
% [bootstat,bootsam] = bootstrp(1000,@(x) det(cov(x)),a);
% clear bootsam
% sigma_val = det(cov(a)); 
% sigma_val = 500; %(quantile(bootstat,.01)); 
% clear bootstat
signlab = ones(size(a,1),1);
nrtar = length(find(signlab==1));
nrout = length(find(signlab==-1));
warning off; % we could get divide by zero, but that is ok.
C(1) = 1/(nrtar*fracrej(1));
C(2) = 1/(nrout*fracrej(2));
warning on;

% sigma_val = bandwith of kernel, +a is positive rep. of signal - cols are
% signals,

[alf,R2,~,J] = svdd_optrbf(sigma_val,+a,signlab,C);
SVx = +a(J,:);
alf = alf(J);

% Compute the offset (not important, but now gives the possibility to
% interpret the output as the distance to the center of the sphere)
offs = 1 + sum(sum((alf*alf').*exp(-sqeucldistm(SVx,SVx)/(sigma_val*sigma_val)),2));

% store the results
W.s = sigma_val;
W.a = alf;
W.threshold = offs+R2;
W.sv = SVx;
W.offs = offs;

K = zeros(length(W.a),size(X,1));
% fprintf(1,'%s\n','Evaluating Kernel Matrix'); 
for j = 1 : size(X,1)
    K(:,j) = evalsvdd(X(j,:),W); 
%     for i = 1 : length(W.a)
%         K(i,j) = W.a(i)*exp(-norm(X(j,:)-W.sv(i,:),2)/W.s); 
%     end
end
SVDD = W.offs + sum(K,1) ;
% t = quantile(SVDD,alpha_val); 
% outlier_position = SVDD <= t ; 
toc 
end

