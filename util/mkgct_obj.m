classdef mkgct_obj
    properties
        fname ; 
        ge ; 
        gn ; 
        gd ; 
        sid ; 
    end
    methods
        function obj = mkgct_obj(fname)
            [obj.ge,obj.gn,obj.gd,obj.sid] = parse_gct(fname); 
            obj.fname = pullname(fname); 
        end
        function draw_dist(obj)
            figure
            subplot(121)
            hist(obj.ge(:),30)
            xlabel('Expression'); 
            title(dashit(obj.fname)); 
            subplot(122)
            boxplot(obj.ge,'plotstyle','compact','orientation',...
                'horizontal')
            title('Sample Distributions')
            xlabel('Expression'); 
            set(gca,'YTickLabel',{' '}); 
            xlim([min(obj.ge(:)),max(obj.ge(:))])
            
            figure
            hist(safe_log2(obj.ge(:)),30)
            xlabel('Log2 Expression'); 
        end    
    end
end
        