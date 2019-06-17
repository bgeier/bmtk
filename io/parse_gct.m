%PARSE_GCT Read .gct Gene expression data format
% [GE,GN,GD,SID] = PARSE_GCT(FNAME)
% Reads .gct file FNAME and returns the gene expression GE, gene names GN,
% gene description GD, and sample id labels SID
% 
% [GE,GN,GD,SID] = PARSE_GCT(FNAME, 'class', CLASS)
% Sets the class of GE to CLASS. See CLASS.
%
% Format Details:
% The first line contains the version string and is always the same for
% this file format. Therefore, the first line must be as follows:
% #1.2
% 
% The second line contains numbers indicating the size of the data table
% that is contained in the remainder of the file. Note that the name and
% description columns are not included in the number of data columns.
% Line format: (# of data rows) (tab) (# of data columns)
% Example: 7129 58
% 
% The third line contains a list of identifiers for the samples associated
% with each of the columns in the remainder of the file.
% Line format: Name(tab)Description(tab)(sample 1 name)(tab)(sample 2 name) (tab) ... (sample N name)
% Example: Name Description DLBC1_1 DLBC2_1 ... DLBC58_0
% 
% The remainder of the data file contains data for each of the genes. There
% is one row for each gene and one column for each of the samples. The
% number of rows and columns should agree with the number of rows and
% columns specified on line 2. Each row contains a name, a description, and
% an intensity value for each sample. Names and descriptions can contain
% spaces, but may not be empty. If no description is available, enter a
% text string such as NA or NULL. Intensity values may be missing. To
% specify a missing intensity value, leave the field empty:
% ...(tab)(tab).... 
% 
% Line format: (gene name) (tab) (gene description) (tab) (col 1 data) (tab) (col 2 data) (tab) ... (col N data)
% Example: AFFX-BioB-5_at AFFX-BioB-5_at (endogenous control) -104 -152 -158 ... -44
%
%CAVEAT: this code does not handle missing values

% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:46 EDT

% 2/22/2008, GE changed to single precision to save memory

function [ge,gn,gd,sid] = parse_gct(fname,varargin)

pnames = {'-class','-struct'};
dflts =  {'single', true};
% [eid, emsg, midx, classname] = ...
%                 getargs(pnames, dflts, varargin{:});
arg = getargs2(pnames, dflts, varargin{:});
validclass={'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64','logical'};

%check if valid cc type
if ~isvalidstr(arg.class, validclass)
    error('Invalid classname: %s\n',arg.class);
end

if isstruct(fname)
    %required fields
    reqfn = {'ge','gn','gd','sid'};
    fn = fieldnames(fname);
    if isempty(setdiff(reqfn, fn))       
        ge = fname.ge;
        gn = fname.gn;
        gd = fname.gd;
        sid = fname.sid;
        clear('fname');
    else        
        error('input does not have required fields');
    end
elseif ischar(fname)
    
    % if matfile , load it
    [p,f,e] = fileparts(fname);
    
    if (strmatch('.mat',lower(e)))
        
        %required fields
        reqfn = {'ge','gn','gd','sid'};
        fn = who('-file', fname);
        
        if isempty(setdiff(reqfn, fn))
            
            load (fname);
        else
            
            error('.mat file does not have required fields');
        end
        
        
    else
        
        %try lowmem=1 for memory efficient(slower) parsing
        lowmem=0;
        
        try
            fid = fopen(fname,'rt');
        catch
            rethrow(lasterror);
        end
        
        %read headerlines
        %first line
        l1=fgetl(fid);
        
        %second line
        l2=fgetl(fid);
        
        %number of features(genes) and samples
        [nr,nc]=strread(l2,'%d\t%d');
        
        %third line
        l3=fgetl(fid);
        
        x=strread(l3,'%s','delimiter','\t');
        
        %sample ids
        sid={(x{3:end})}';
        
        nsamples = length(sid);
        
        %gene expression data (single precision to save space)
        % ge=zeros(nr,nc);
        
        %gene name
        gn=cell(nr,1);
        %gene description
        gd=cell(nr,1);
        
        fprintf('class:%s\n', arg.class);
        
        switch(arg.class)
            case {'double','single'}
                ge=zeros(nr, nc, arg.class);
                classfmt = '%f';
            case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
                ge=zeros(nr, nc, arg.class);
                classfmt = '%d';
            case {'logical'}
                ge = false(nr, nc);
                classfmt = '%d';
        end
        
        fmt=['%s%s',repmat(classfmt,1,nsamples)];
        
        fprintf ('Reading %s [%dx%d]\n',fname, nr,nc);
        %read line by line
        if (lowmem)
            x=cell(1,nsamples+2);
            for r=1:nr;
                %         x=strread(fgetl(fid),'%s','delimiter','\t');
                [x{:}]=strread(fgetl(fid),fmt,'delimiter','\t');
                gn{r}=char(x{1});
                gd{r}=char(x{2});
                ge(r,:) = [x{3:end}];
            end
        else
            
            %line count
            %         lc = linecount(fname) - 3;
            lc = nr;
            
            %max number of lines per read block
            maxline = 4000;
            
            %max buffer size (bytes)
            maxbuf = 100000;
            
            iter=ceil(lc/maxline);
            
            lctr=0;
            skip=3;
            x=cell(1,nsamples+2);
            
            for l=1:iter
                
                %         full=textread(fname,'%s',maxline,'delimiter','\n','bufsize',maxbuf,'headerlines',skip);
                [x{:}]=textread(fname,fmt,maxline,'delimiter','\t','bufsize',maxbuf,'headerlines',skip);
                
                if (lctr+maxline > lc)
                    nrows = lc-lctr;
                else
                    nrows = maxline;
                end
                
                %		x=strread(full{r+3},'%s','delimiter','\t');
                %             [x{:}]=strread(full{r},fmt,'delimiter','\t');
                
                gn(lctr+(1:nrows))=x{1};
                gd(lctr+(1:nrows))=x{2};
                ge(lctr+(1:nrows),:) = [x{3:end}];
                
                skip = 3 + l*maxline;
                lctr = l*maxline;
                fprintf('read:%d/%d\n',min(lctr,lc),lc);
            end
        end
        
        fprintf ('Done.\n');
        fclose(fid);
    end
end



