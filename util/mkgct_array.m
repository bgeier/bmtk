classdef mkgct_array
    properties
        fname ; 
        ge ; 
        gn ; 
        gd ; 
        sid ; 
    end
    methods
        function obj = mkgct_array(fname)
            [obj.ge,obj.gn,obj.gd,obj.sid] = parse_gct(fname); 
            obj.fname = pullname(fname) ; 
        end
    end
end
        