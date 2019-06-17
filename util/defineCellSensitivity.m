function [classes,yval] = defineCellSensitivity(nsc_obj,LineNames)


[~,i,j] = intersect_ord(LineNames,fixNSC(nsc_obj.CellLineName));


classes = cell(size(LineNames));
y = str2double(nsc_obj.logValue );


cidx = kmeans(zscore(y(j)),3,'Replicates',5);
[~,ix] = sort(cidx);
figure(findNewHandle)
subplot(121)
plot(zscore(y(j(ix))),'.')
grid on 

subplot(122)
hold on 
grid on 
colors = mkcolorspec(3); 
z = zscore(y(j)); 
for ii = 1 : 3
    [f,x] = ecdf(z(cidx==ii)); 
    stairs(x,f,colors{ii}); 
end


classes(i) = cellstr([repmat('class-',[length(i),1]),num2str(cidx)]);
flag = ones(size(classes)); 
flag(i) = 0 ; 
classes(logical(flag)) = {'unknown'}; 

yval = zeros(size(classes)); 
yval(logical(flag)) = nan; 

yval(i) = z ; 