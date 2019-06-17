function plot_af_chr(events,af,position,allele) 

% exonic = {'frameshift deletion','frameshift insertion',...
%     'nonframeshift deletion','nonframeshift insertion',...
%     'synonymous SNV','frameshift substitution',...
%     'nonframeshift substitution'};
% for i = 1 : length(exonic)
%     events(strcmp(exonic{i},events)) = {'exonic'} ;
% end
% 
% utr = {'UTR3','UTR5','UTR5;UTR3'}; 
% for i =  1 : length(utr)
%     events(strcmp(utr{i},events)) = {'UTR'} ;
% end
% 
% events(strcmp('upstream',events)) = {'upstream;downstream'}; 
% events(strcmp('downstream',events)) = {'upstream;downstream'}; 

events = consolidate_events(events); 


uniq_events = unique(events) ; 
[color,spec] = mkcolorspec(length(uniq_events)); 
color(strcmp('black',color))={'white'}; % using black background

figure, hold on

for i = 1 : length(uniq_events)
    plot(position(strcmp(uniq_events{i},events)),...
        af(strcmp(uniq_events{i},events)),...
        [color{i},spec{i}],'MarkerSize',10)
end
legend(uniq_events,'Location','EastOutside')
for i = 1 : length(uniq_events)
    plot(position(strcmp(uniq_events{i},events)&strcmp('het',allele)),...
        af(strcmp(uniq_events{i},events)&strcmp('het',allele)),...
        [color{i},'o'],'MarkerSize',8)
end

ylabel('1000 Genome Allelic Frequency');
xlabel('Chromosome Start Position')

ylim([0,1])
xlim([min(position)-10^3,max(position)+10^3])
set(gcf,'Position',[15,712,1893,358])

figure, hold on ; 
B = 100; show_events = ones(1,length(uniq_events)); event_thresh = 50 ; 
interp_method = 'nearest'; 
for i = 1 : length(uniq_events)
    x = position(strcmp(uniq_events{i},events));
    y = af(strcmp(uniq_events{i},events)) ; 
    if length(x) < event_thresh
        show_events(i) = 0; 
        continue
    end
    [~,ix] = unique(x); 
    x = x(ix); y = y(ix); 
    plot(linspace(min(x),max(x),B),interp1(x,y,...
        linspace(min(x),max(x),B),interp_method),...
        [color{i},spec{i}],'MarkerSize',10)
    
end
legend(uniq_events(logical(show_events)),'Location','EastOutside')

for i = 1 : length(uniq_events)
    x = position(strcmp(uniq_events{i},events));
    y = af(strcmp(uniq_events{i},events)) ; 
    if length(x) < event_thresh
        continue
    end
    [~,ix] = unique(x); 
    x = x(ix); y = y(ix); 
    plot(linspace(min(x),max(x),B),interp1(x,y,...
        linspace(min(x),max(x),B),interp_method),...
        [color{i},'-'],'MarkerSize',10)
end

ylabel('Interpolated 1000 Genome Allelic Frequency');
xlabel('Chromosome Start Position')

ylim([0,1])
xlim([min(position)-10^3,max(position)+10^3])
set(gcf,'Position',[15,712,1893,358])
