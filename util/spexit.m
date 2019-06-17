function spexit

clear all ; 

try
    matlabpool close force  ; 
    exit
catch em
    disp(em);
    exit
end