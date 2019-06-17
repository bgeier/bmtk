function vcf = parse_vcf(fname)
tic
system(['grep -v ''##'' ',fname,' > tmp.txt']); 

system('sed ''s/#CHROM/CHROM/g'' tmp.txt > tmp2.txt');

vcf = parse_frame('tmp2.txt'); 

system('rm tmp.txt tmp2.txt'); 

% num_lines = length(vcf.INFO); 

INFO = vcf.INFO; 

t = textscan(INFO{1},'%s','Delimiter',';'); 
t = t{1}; header = cell(length(t),1); 
for j = 1 : length(t)
    s = textscan(t{j},'%s','Delimiter','='); 
    s = s{1}; 
    header{j} = s{1}; 
end

% covariates = zeros(num_lines,length(header)); 
% num_covariates = length(header); 
% % h = waitbar(0,'Pooling covariates ... '); 
% parfor i = 1 : num_lines
%     t = textscan(INFO{i},'%s','Delimiter',';'); 
%     t = t{1}; 
%     if length(t) ~= num_covariates
%         t = fixtags(t); 
%     end
%     tmp = zeros(1,num_covariates); 
%     for j = 1 : length(header)
%         idx = find(t{j}=='=');
%         r = t{j}; 
%         r(1:idx)=[];
%         tmp(j) = str2double(r); 
%     end
%     
% %     if length(t) ~= num_covariates
% %         tmp = NaN*ones(1,num_covariates); 
% %     else
% %         for j = 1 : length(t)
% %             s = textscan(t{j},'%s','Delimiter','='); 
% %             s = s{1}; 
% %             try 
% %                 tmp(j) = str2double(s{2}); 
% %             catch
% %                 tmp(j) = NaN; 
% %             end
% %         end
% %     end
%     covariates(i,:) = tmp; 
% %     waitbar(i/num_lines,h); 
% end
% % close(h) ;

vcf.QUAL = str2double(vcf.QUAL); 
vcf.POS = str2double(vcf.POS); 
% vcf.covariates = covariates; 
% vcf.features = header ; 
toc

end

% function tags = fixtags(tags)
% 
% idx = zeros(length(tags),1); 
% for i = 1 : length(tags)
%     if sum(tags{i}=='=')==0
%         idx(i) = 1; 
%     end
% end
% tags(logical(idx)) = []; 
% 
% end