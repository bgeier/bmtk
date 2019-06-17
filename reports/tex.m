function tex(list,varargin)
% TEX   Writes and compiles a foo.tex - summarizing EDA design imagery
%   TEX(list,varargin) will make a foo.tex file given the image locations
%   specified in list. The list structure allows for a nested factor
%   design, which currently is a K factor K-level nested design. The
%   foo.tex file is compiled using the beamer document class. A .pdf file
%   will be created at run-time but may error if pdflatex is not installed
%   at system level. 
%   Inputs: 
%       list: a structure object . list.name - factor A name,
%       list.instance.name - factor B nested under A name,
%       list.instance.location - a cell array which specifies the location
%       of the images for factor A (level i), nested factor B (level j)
%       varargin
%           '-out': The output directory, default=pwd
%           '-fname': The fullfile(pathname,filename), i.e. foo_dir/foo.tex 
%   Outputs: 
%       A foo.tex file will be created and compiled in the directory '-out'
%   Warnings:
%       The number of images cannot exceed the tex compiler. An error at 
%       compiling may result if there are too many images. If pdflatex is
%       not installed at system level, then the document can be compiled
%       manuually with TexShop. 
%
%   See also pdflatex
% 
% Author: Brian Geier, Broad 2010

toolName = mfilename ; 

pnames = {'-out','-fname','-table','-params','-watermark','-author','-author_ab'}; 
% dflt_out = get_lsf_submit_dir ; 
dflts = {pwd,'tmp','','','','',''}; 

arg = getargs2(pnames,dflts,varargin{:}); 

print_tool_params2(toolName,1,arg); 

box_scale = 0.6; 

template.line(1).str = '\documentclass{beamer}';
template.line(2).str = '\usepackage{xcolor}'; 

template.line(3).str = '\usepackage[printwatermark]{xwatermark}';
template.line(4).str = '\usepackage{graphicx}';
template.line(5).str = '\usepackage{lipsum}';
template.line(6).str = '\usepackage{tikz}';
template.line(7).str = '\newsavebox\mybox';
template.line(8).str = ['\savebox\mybox{\tikz[color=red,opacity=0.2]\node{',...
    arg.watermark,'};}'];

template.line(9).str = '\newwatermark*[';
template.line(10).str =   'allpages,';
template.line(11).str =   'angle=45,';
template.line(12).str =   'scale=1.75,';
template.line(13).str =   'xpos=-10,';
template.line(14).str =   'ypos=10';
template.line(15).str = ']{\usebox\mybox}';
template.line(16).str = '\setbeamertemplate{footline}[text line]{%';
template.line(17).str =  '\parbox{\linewidth}{\vspace*{-8pt}\hfill\insertshortauthor\hfill\insertpagenumber}}'; 
template.line(18).str = '\begin{document}';

fid = fopen(fullfile(arg.out,horzcat(arg.fname,'.tex')),'w'); 
for i = 1 : 17
    fprintf(fid,'%s\n',template.line(i).str); 
end

if ~isempty(arg.watermark)
    fprintf(fid,'%s\n','\setbeamertemplate{footline}[text line]{%'); 
    fprintf(fid,'%s\n',...
        [' \parbox{\linewidth}{\vspace*{-8pt}',arg.watermark,...
        '\hfill\insertshortauthor\hfill\insertpagenumber}}']); 
    fprintf(fid,'%s\n','\setbeamertemplate{navigation symbols}{}'); 
end

if ~isempty(arg.author)
    fprintf(fid,'%s\n',['\author[',arg.author_ab,']{',...
        arg.author,'}']); 
end

fprintf(fid,'%s\n',template.line(end).str); 

if ~isempty(arg.params)
    params_obj = parse_params(arg.params); % function call params file
    fprintf(fid,'%s\n','\section{Report Parameters}'); 
    fprintf(fid,'%s\n%s\n','\frame{','\begin{itemize}');  
    
    fields = fieldnames(params_obj); 
    for i = 1 : length(fields)
        if strcmp('out',fields{i}), continue, end
        if strcmp('fn_name',fields{i}), continue, end
        fprintf(fid,'%s\t%s: %s\n','\item',insertslash(fields{i}),...
            insertslash(pullname(char(params_obj.(fields{i}))))); 
    end
    fprintf(fid,'%s\n','\end{itemize}'); 
%     fprintf(fid,'%s\n','\begin{table}[ht]');
%     fprintf(fid,'%s\n','\caption{Input Parameters}');  
%     fprintf(fid,'%s\n','\centering'); 
%     fprintf(fid,'%s\n',horzcat('\scalebox{',num2str(0.8),'}{')); 
%     fprintf(fid,'%s\n','\begin{tabular}{| c | c |}');
%     fprintf(fid,'%s\n','\hline\hline');
%     fprintf(fid,'%s\n',...
%         'Parameter & Input \\[0.8ex]');
%     fprintf(fid,'%s\n','\hline'); 
%     fields = fieldnames(params_obj); 
%     for i = 1 : length(fields)
%         fprintf(fid,'%s&%s\n',insertslash(fields{i}),...
%             [insertslash(pullname(char(params_obj.(fields{i})))),' \\']);  
%     end
% 
%     fprintf(fid,repmat('%s\n',[1,5]),'[1ex]',...
%         '\hline','\end{tabular}}','\end{table}'); 
    fprintf(fid,'%s\n','}'); 
end
    
if ~isempty(arg.table)
    
    tbl = parse_frame(arg.table); 
    fprintf(fid,'%s\n','\section{Summary}');
    fprintf(fid,'%s\n','\frame{'); 
    fprintf(fid,'%s\n','\begin{table}[ht]');
    fprintf(fid,'%s\n','\caption{Statistical Summary}');  
    fprintf(fid,'%s\n','\centering'); 
    fprintf(fid,'%s\n',horzcat('\scalebox{',num2str(box_scale),'}{')); 
    fields = fieldnames(tbl);
    c = ['|',repmat(' c |',[1,length(fields)])]; 
    fprintf(fid,'%s\n',['\begin{tabular}{',c,'}']);
    fprintf(fid,'%s\n','\hline\hline');
     
    for ii = 1 : length(fields) - 1
        fprintf(fid,'%s&',insertslash(fields{ii})); 
    end
    fprintf(fid,'%s\n',[insertslash(fields{end}),' \\[0.8ex]']); 
    fprintf(fid,'%s\n','\hline');
    
    % Insert data
    num_lines = length(getfield(tbl,fields{1})); 
    for i = 1 : num_lines
        for j = 1 : length(fields) - 1
            fprintf(fid,'%s&',char(getfield(tbl,fields{j},{i}))); 
        end
        fprintf(fid,'%s\n',[char(getfield(tbl,fields{end},{i})),' \\ \hline']);
    end   

    fprintf(fid,'%s\n%s\n%s\n',...
        '\hline','\end{tabular}}','\end{table}}'); 
end
    

for i = 1 : length(list)
    fprintf(fid,'%s\n',horzcat('\section{',list(i).name,'}')); 
    for j = 1 : length(list(i).instance)
        sublabel = insertslash(list(i).instance(j).name);
        fprintf(fid,'%s\n',horzcat('\subsection{',sublabel,'}')); 
        for k = 1 : length(list(i).instance(j).location)
            fprintf(fid,'%s\n','\frame{');
            label = list(i).instance(j).location{k} ;
            fprintf(fid,'%s\n',horzcat('\frametitle{',...
                insertslash(pullname(label)),'}')); 
            fprintf(fid,'%s\n',horzcat(...
                '\includegraphics[height=80mm,width=100mm]{',label,'}')); 
            fprintf(fid,'%s\n','}');
        end
    end
end

fprintf(fid,'%s\n','\end{document}'); 
fclose(fid); 

try

%     pdflatex(fullfile(arg.out,horzcat(arg.fname,'.tex')));
%     pdflatex(fullfile(arg.out,horzcat(arg.fname,'.tex')));
    pdflatex(fullfile(arg.out,horzcat(arg.fname,'.tex')),'-cleanup',1);
catch err
    disp(err)
    fprintf(1,'%s\n','Unable to compile tex source.. try manually');
end