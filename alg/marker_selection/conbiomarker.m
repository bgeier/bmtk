function [markers,consensus,marker_union] = conbiomarker(ge,cls,k,just_up)
% CONBIOMARKER    Finds the biomarker using leave-one out cross validation
%   [markers,consensus,marker_union] =
%   conbiomarker(ge,cls,k,just_up) will discover the biomarkers
%   with the most resistance to sampling variability, i.e. those
%   markers that are present consistently across leave-one out
%   iterations. 
%   Inputs: 
%       ge - an n by p data matrix. 
%       cls - a structure with fields 'labels' and 'num_classes',
%       where cls.labels is a cell array which specifies each
%       samples phenotype membership. 
%       k - the number of biomarkers desired
%       just_up - a logical indiactor; 1=> only up regulated
%       markers , 0=> both up and down regulated markers 
%   Outputs: 
%       markers - a 1 by k (only up-regulated) or 1 by 2*k (both up
%       and down regulated) biomarkers . The order is by fold
%       change, going highest to lowest. 
%       consensus - a structure with fields 'up' and 'down'. Each
%       value is the rate at which that gene appears as a biomarker
%       across the leave-one out cross validation runs. 
%       markers_union - a structure with fields 'up' and 'down'. Each
%       value is the indices of the union of biomarkers that occur
%       across the leave-one out cross validation runs. 
%   
%   See also multibiomarker
% 
% Author: Brian Geier, Broad 2010

spopen  ; 
if ~exist('just_up','var')
    just_up = 0; 
end
n = size(ge,1); 
trkmarkers = zeros(n,k,2); 
fprintf(1,horzcat('Estimated time for consensus biomarker selection is ',...
    num2str((n*4)/60),' minutes.')); 
% classes = unique(cls.labels); 
h = waitbar(0,'Running leave-one out biomarker consensus...'); 
if any(strcmp(cls.labels,'background'))
    ids = unique_ord(cls.labels); 
    if length(ids) == 2
        ref = ids(~strcmp('background',ids)); 
    end
end

for i = 1 : n 
    if exist('ref','var')
        [pvalue,regulation] = updateMarkers(ge,cls,i,ref); 
    else
        [pvalue,regulation] = updateMarkers(ge,cls,i); 
    end
    
    idx = find(regulation==1); 
    if ~isempty(idx)
        [~,ix] = sort(pvalue(idx)); 
        trkmarkers(i,:,1) = idx(ix(1:k)); 
    end
    idx = find(regulation==-1); 
    if ~isempty(idx)
        [~,ix] = sort(pvalue(idx)); 
        trkmarkers(i,:,2) = idx(ix(1:k)); 
    end
    waitbar(i/n,h); 
end
close(h); 

[markers.up,consensus.up] = getmarkercon(squeeze(trkmarkers(:,:,1)),n,k); 
[markers.down,consensus.down] = getmarkercon(squeeze(trkmarkers(:,:,2)),n,k); 
marker_union.up = unique(squeeze(trkmarkers(:,:,1))); 
marker_union.down = unique(squeeze(trkmarkers(:,:,2))); 

% chkcon(ge,markers,marker_union,consensus,cls,k); 

if just_up
    markers = markers.up(:); 
else
    markers = [markers.up(:) ; markers.down(:)]; 
end