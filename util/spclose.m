function okay = spclose

try
    matlabpool close force local  ; 
    okay = true; 
catch em
    disp(em)
    okay = false; 
end