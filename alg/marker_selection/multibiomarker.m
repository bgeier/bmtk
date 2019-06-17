function [markers,full_markers] = multibiomarker(ge,cl,k,leave_out,only)

spopen ; 
if nargin == 4
    only = 0 ; 
end

labels = unique_ord(cl); 

markers = zeros(k,length(labels)); 
full_markers = struct('class','','markers','','foldChange',''); 

if only
    cls.labels = cl;
    [~,regulation,obsStat] = updateMarkers(ge',cls,[],labels{1});
    ix_up = find(regulation> 0);
    ix_down = find(regulation < 0); 
    [~,ix_down_stats] = sort(obsStat(regulation<0),'ascend');
    [~,ix_up_stats] = sort(obsStat(regulation>0),'descend');
    markers(:,1) = ix_up(ix_up_stats(1:k));
    markers(:,2) = ix_down(ix_down_stats(1:k)); 
    full_markers.class = labels{1}; 
    [full_markers.foldChange,full_markers.markers] = ...
        sort(obsStat,'descend'); 
else

    if ~leave_out

        h = waitbar(0,'Running Multiple Marker Selection...'); 
        for i = 1 : size(markers,2)
            cls.labels = cl;
            cls.labels(~strcmp(labels{i},cl)) = {'background'};
            [~,regulation,obsStat] = updateMarkers(ge',cls,[],labels{i});
            ix_up = find(regulation> 0);
            [~,ix_up_stats] = sort(obsStat(regulation>0),'descend');
            markers(:,i) = ix_up(ix_up_stats(1:k));
            full_markers(i).class = labels{i}; 
            [full_markers(i).foldChange,full_markers(i).markers] = ...
                sort(obsStat,'descend'); 

            waitbar(i/size(markers,2),h)
        end
        close(h) ; 
    else

        for i = 1 : size(markers,2)
            cls.labels = cl;
            cls.labels(~strcmp(labels{i},cl)) = {'background'};
            markers(:,i) = conbiomarker(ge',cls,k,1);
        end

    end
end