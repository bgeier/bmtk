function db_struct = parse_db(fname)

db_struct = struct('bin','','chr','','start','','end','','name','',...
    'score','','strand','','refNCBI','','refUCSC','','observed','',...
    'molType','','class','','valid','','avHet','','avHetSE','',...
    'func','','locType','','weight',''); 
fid = fopen(fname); 
c = textscan(fid,repmat('%s',[1,18]),'Delimiter','\t'); 
fclose(fid); 

fields = fieldnames(db_struct); 
for i = 1 : length(fields)
    eval(['db_struct.',fields{i},'=c{',num2str(i),'};'])
end
