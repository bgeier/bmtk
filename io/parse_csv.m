% PARSE_CSV Parse a Luminex CSV file
% GCT = PARSE_CSV(FN)
% GCT = PARSE_CSV(FN, ...) the filename can be followed by additional
% parameter/value pairs.
% 

function gct = parse_csv(fname,varargin)

pnames = {'-type', '-class'};
dflts =  {'median', 'double'};
arg = getargs2(pnames, dflts, varargin{:});

dsfile = parse_filename(fname, '-wc', '*.csv');

nds = length(dsfile);
ds = struct('ge',[],'gn',[],'gd',[],'sid',[]);
for ii=1:nds
    try
        fprintf ('Reading: %s ', dsfile{ii});
        fid = fopen(dsfile{ii}, 'rt');
    catch
        rethrow(lasterror);
    end
    nc = 0;
    isdtfound = false;
    while ~feof(fid)
        x = csv_read_line(fid);
        issample = ~isempty(strmatch('Samples',x));
        isdatatype = ~isempty(strmatch('DataType:',x));
        
        if issample
            nc = str2double(x(2));
        elseif isdatatype
            if strmatch(lower(arg.type), lower(x))
                isdtfound = true;
                break
            end
        end
        
    end
    if isdtfound
        gct(ii) = parse_csvblock(fid, nc, arg);
        fclose(fid);
        fprintf ('Done.\n');
    end
    
end
end

function gct = parse_csvblock(fid, nc, arg)
    gct = struct('ge', [], 'gn', [],'gd', [], 'sid', []);    
    r = csv_read_line(fid);
    gct.gn = r(3:end-1);
    gct.gd = gct.gn;
    nr = length(gct.gn);
    fprintf ('[%dx%d]\n', nr, nc);
    gct.ge = zeros(nr, nc, arg.class);
    gct.sid = cell(nc,1);
    for ii=1:nc
        r = csv_read_line(fid);
        if isempty(r)
            break
        else
            gct.sid{ii} = r{1};
            % set nan's to zero
            gct.ge(:, ii) = max(str2double(r(3:end-1)), 0);
        end
    end
end

function line = csv_read_line(fid)
line = strread(fgetl(fid),'%q','delimiter',',');
end
