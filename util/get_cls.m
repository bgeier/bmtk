function cl = get_cls

[filename,pathname] = uigetfile({'*.cls'},...
    'ooo.....ooo'); 

cl = parse_cls(fullfile(pathname,filename)); 
