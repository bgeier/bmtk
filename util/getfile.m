function [pathname,filename] = getfile(name)

[~,result] = system(['find . -name "',name,'"']); 

[pathname,n,e] = fileparts(result); 
filename = [n,e]; 
pathname(1:2)=[];