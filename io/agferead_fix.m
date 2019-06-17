function outStruct = agferead_fix(filename)
%AGFEREAD reads Agilent Feature Extraction Format files.
%
%   AGFEDATA = AGFEREAD(FILE) reads in Agilent Feature Extraction format data
%   from FILE and creates a structure AGFEDATA, containing these fields:
%           Header
%           Stats
%           Columns
%           Rows
%           Names
%           IDs
%           Data
%           ColumnNames
%           TextData
%           TextColumnNames
%
%   Example:
%
%       % Read in a sample Agilent Feature Extraction file and plot the
%       % median foreground. [Note that fe_sample.txt is not provided.]
%
%       agfeStruct = agferead('fe_sample.txt')
%       maimage(agfeStruct,'gMedianSignal');
%       figure
%       maboxplot(agfeStruct,'gMedianSignal');
%
%   See also AFFYREAD, CELINTENSITYREAD, GALREAD, GEOSOFTREAD, GPRREAD,
%   ILMNBSREAD, IMAGENEREAD, MAGETFIELD, SPTREAD.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.10.6 $   $Date: 2009/11/05 16:57:55 $

bioinfochecknargin(nargin,1,mfilename);

% Open the file
try
    fopenMessage = '';
    [fid, fopenMessage] = fopen(filename,'rt');
catch theException %#ok<NASGU>
    fid = -1;
end

if fid == -1
    error('Bioinfo:agferead:CannotOpenFEFile',...
        'Problem opening file %s. %s',filename,fopenMessage);
end

% See how many blocks of data we have. It seems that the typical chunks are
% the FEPARAMS, STATS and FEATURES.
fields =  textscan(fid,'%s%*[^\n]','bufsize',65536);
typeLineNums = find(strcmpi(fields{1},'TYPE'));
breakLineNums = find(strcmpi(fields{1},'*'));
fseek(fid,0,-1);

% find the data chunk break lines
numBlocks = numel(typeLineNums);
if numel(breakLineNums) < numBlocks
    breakLineNums(end+1) = length(fields{1})+1;
end

% For each block read in the format line, the header line and then read in
% the data using the format. The files treat float, integer and Boolean as
% different types but we treat everything as double.
for count = 1:numBlocks
    % Read the type line
    typeLine = fgetl(fid);
    % Figure out the format
    formatLine = makeFormatLine(typeLine);
    % The headers are all strings, we just need to know how many to read
    hFormat = repmat('%s',1,numel(formatLine)/2);
    headers = textscan(fid,hFormat,1,'delimiter','\t');
    % figure out how many lines to read
    dataLength = breakLineNums(count) - typeLineNums(count) -2;
    % And read the data
    data = textscan(fid,formatLine,dataLength,'delimiter','\t');
    % For all but the last block look for a line with a '*'
    if count< numBlocks
        dummyLine = fgetl(fid);
        % currently we don't check that we found a * but just check that we
        % find a non-empty line
        while isempty(dummyLine)
            dummyLine = fgetl(fid);
        end
    end
    % store the data in a structure for processing later
    dataStruct.(fields{1}{typeLineNums(count)+1}).headers = headers;
    dataStruct.(fields{1}{typeLineNums(count)+1}).data = data;
    dataStruct.(fields{1}{typeLineNums(count)+1}).isText = (strrep(formatLine,'%','')=='s');
end

fclose(fid);

% FEPARAMS contains the setup information for the extractor. Store this in
% the header field.
if isfield(dataStruct,'FEPARAMS')
    outStruct.Header = cell2struct([dataStruct.FEPARAMS.data{:}],[dataStruct.FEPARAMS.headers{:}],2);
    % remove the field FEPARAMS. An alternative is to do data{2:end} but
    % this can get us into trouble if all the data types are numeric in
    % which case we get a double array not a cell array which causes
    % cell2struct to fail. This seems to be most likely in the STATS field.
    outStruct.Header.Type = 'FeatureExtractor';
    outStruct.Header = rmfield(outStruct.Header,'FEPARAMS');
else
    outStruct.Header.Type = 'FeatureExtractor';
end

% STATS field contains global statistics
if isfield(dataStruct,'STATS')
    outStruct.Stats = cell2struct(dataStruct.STATS.data,[dataStruct.STATS.headers{:}],2);
    outStruct.Stats = rmfield(outStruct.Stats,'STATS');
else
    outStruct.Stats = [];
end

% The main data is in the FEATURES field
if isfield(dataStruct,'FEATURES')
    headers = dataStruct.FEATURES.headers;
    % explicitly extract the columns, rows, genenames and SystematicName
    % (AccessionNumber)
    colCol = getCol(headers,'col');
    outStruct.Columns = dataStruct.FEATURES.data{colCol};
    rowCol = getCol(headers,'row');
    outStruct.Rows = dataStruct.FEATURES.data{rowCol};
    geneCol = getCol(headers,'ProbeName');
    outStruct.Names = dataStruct.FEATURES.data{geneCol};
    idCol = getCol(headers,'SystematicName');
    outStruct.IDs = dataStruct.FEATURES.data{idCol};
    % Stuff all the other features into a big array
    outStruct.Data = [dataStruct.FEATURES.data{~dataStruct.FEATURES.isText}];
    outStruct.ColumnNames = [headers{~dataStruct.FEATURES.isText}];
    % Put the text features in a cell array
    textMask = dataStruct.FEATURES.isText;
    textMask([1 geneCol idCol]) = false;
    outStruct.TextData = [dataStruct.FEATURES.data{textMask}];
    outStruct.TextColumnNames = [headers{textMask}];
else
    outStruct.Data = [];
end

% hide the column lookup
function theCol = getCol(headers,label)
theCol = find(strcmpi(label,[headers{:}]));

% make the format line
function formatLine = makeFormatLine(typeLine)
formatLine = strrep(typeLine,'TYPE','%s');
formatLine = strrep(formatLine,'text','%s');
formatLine = strrep(formatLine,'boolean','%f');
formatLine = strrep(formatLine,'integer','%f');
formatLine = strrep(formatLine,'float','%f');
formatLine = strrep(formatLine,sprintf('\t'),'');


