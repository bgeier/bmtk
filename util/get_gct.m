function [ge,gn,gd,sid] = get_gct

[filename,pathname] = uigetfile({'*.gct;*.mat'},...
    'ooo.....ooo'); 

[ge,gn,gd,sid] = parse_gct(fullfile(pathname,filename));

