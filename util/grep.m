function [status,result] = grep(str,fname)

[status,result] = system(['grep ',str,' ',fname]); 