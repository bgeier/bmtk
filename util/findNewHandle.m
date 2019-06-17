function h = findNewHandle

open = get(0,'children');
if length(open) == 0
    h = 1; 
else
    
    h = length(open); 
end
% if isempty(open)
%     h = 1 ; 
% else
%     h = round(max(open) + 1); 
% end
% if ~isscalar(h)
%     h = 1; 
% end

