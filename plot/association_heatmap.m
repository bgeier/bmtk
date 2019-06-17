function association_heatmap(sample_struct,chr,index,sample_order)


% sample_struct(i): n - entries
%         data: {1x13 cell}
%         name: 'C1970'
%          chr: {113581x1 cell}
%        start: [113581x1 double]
%       events: {113581x1 cell}
%     vcf_vals: [113581x1 double]
%       allele: {113581x1 cell}

num_samples = length(sample_struct); 

if nargin == 3
    sample_order = 1:num_samples ; 
end
    
sample_struct = sample_struct(sample_order); 
% min_vals = zeros(1,num_samples); 
% max_vals = zeros(1,num_samples); 
% for i = 1 : num_samples
%     chr_idx = strcmp(chr,sample_struct(i).chr);
%     min_vals(i) = min(sample_struct(i).start(chr_idx)); 
%     max_vals(i) = max(sample_struct(i).start(chr_idx));
% end

index = index(1):index(2);%min(min_vals):max(max_vals); 
% tile array with patient info by position
vals = ones(range(index),num_samples)*1.1; 
names = cell(1,num_samples); 
for i = 1 : num_samples
    chr_idx = find(strcmp(chr,sample_struct(i).chr));
    [~,idx,idx2] = intersect_ord(index,sample_struct(i).start(chr_idx)); 
    vals(idx,i) = sample_struct(i).vcf_vals(chr_idx(idx2)); 
    names{i} = sample_struct(i).name; 
end
drop = sum(vals==1.1,2) == num_samples; 
vals(drop,:)=[];
index(drop) = [];
figure
imagesc(vals), colormap bluepink
colorbar
hold on ; 
for j = 1 : num_samples
    idx = (strcmp(chr,sample_struct(j).chr)&...
        strcmp('het',sample_struct(j).allele));
    
    [~,idx] = intersect_ord(index,...
        sample_struct(j).start(idx)); 
    plot(repmat(j,[length(idx),1]),idx,'yx')
    idx = (strcmp(chr,sample_struct(j).chr)&...
        strcmp('hom',sample_struct(j).allele));
    [~,idx] = intersect_ord(index,...
        sample_struct(j).start(idx));
    plot(repmat(j,[length(idx),1]),idx,'y.')
        
%     events = consolidate_events(sample_struct(i).events(chr_idx)); 
%     uniq_events = unique(events) ; 
%     [color,spec] = mkcolorspec(length(uniq_events)); 
%     for i = 1 : length(uniq_events)
%         [~,idx] = intersect_ord(index,...
%             sample_struct(j).start(chr_idx(strcmp(uniq_events{i},events))));  
%         plot(repmat(j,[length(idx),1]),idx,[color{i},spec{i}],'MarkerSize',10)
%     end
end
set(gca,'XTick',1:num_samples,'XTickLabel',names,...
    'YTickLabel',index); 