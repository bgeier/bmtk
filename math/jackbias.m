function jbias = jackbias(x,fun)

opts = statset('UseParallel','always'); 
m = jackknife(fun,x,'Options',opts); 
n = length(x); 
jbias = (n-1)*(mean(m)-var(x,1)); 
