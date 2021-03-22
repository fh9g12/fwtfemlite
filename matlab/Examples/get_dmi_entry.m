function X = get_dmi_entry(name,filename)
    %Get raw text from the file
    bd = readCharDataFromFile(filename);
    tic
    bd = extractBulkData(bd);
    dmi_cards = cellfun(@(x)strcmp(x{1},'DMI'),bd) & cellfun(@(x)strcmp(x{2},name),bd) ;
    dmi_cards = bd(dmi_cards);
    dmi_meta = cellfun(@(x)str2double(x{3})==0,dmi_cards);
    meta = dmi_cards{dmi_meta};
    X = zeros(str2double(meta{8}),str2double(meta{9}));
    X_data = dmi_cards(~dmi_meta);
    for i = 1:length(X_data)
        tmp = str2double(X_data{i}(5:554));
        row = str2double(X_data{i}{3});
        X(:,row) = tmp;
    end
    toc
end



function rawFileData = readCharDataFromFile(filename, logfcn)
%readCharDataFromFile Reads the data from the file as literal text and
%return a cell-array where each element is a line in the file.
%
% Syntax:
%	- Extract the file data as text:
%       >> filename = 'mySampleFile.txt';
%       >> rawFileData = readCharDataFromFile(filename);
%   - Extract the file data and send diagnostics to a log function:
%       >> filename = 'mySampleFile.txt'
%       >> logfcn   = @(s) fprintf('%s\n', s)
%       >> rawFileData = readCharDataFromFile(filename, logfcn);
%
% Detailed Description:
%	- Extracts the data from the file whilst skipping comments 
%   - A comment is any line beginning with '$'.
%   - Also removes inline comments
%
% See also: 
%
% References:
%	[1]. 
%
% Author    : Christopher Szczyglowski
% Email     : chris.szczyglowski@gmail.com
% Timestamp : 19-Apr-2020 15:01:44
%
% Copyright (c) 2020 Christopher Szczyglowski
% All Rights Reserved
%
%
% Revision: 1.0 19-Apr-2020 15:01:45
%	- Initial function:
%
% <end_of_pre_formatted_H1>

if nargin < 2
   logfcn = @(s) fprintf(''); %dummy function
end

%Grab file identifier
fileID = fopen(filename, 'r');
assert(fileID ~= -1, ['Unable to open the file ''%s'' for reading. ', ...
    'Make sure the file name and path are correct.'] , filename);

logfcn(sprintf('Beginning file read of file ''%s'' ...', filename));

%Import all the data as a string
%   - Import literal text (including whitespace)
%   - Remove comments (any line beginning with '$')
rawFileData = textscan(fileID, '%s', ...
    'Delimiter'    , '\n' , ...
    'CommentStyle' , '$'  , ...
    'WhiteSpace'   , '');
rawFileData = rawFileData{1};

% remove inline comments
rawFileData = regexprep(rawFileData,'(.*)[$].*','$1');

%Close the file
fclose(fileID);

%TODO - Check if all data has less than 80 characters

end
function [execControl, caseControl, bulkData, unresolvedBulk] = splitInputFile(data, logfcn)
%splitInputFile Splits the contents of a Nastran file into 'execControl',
%'caseControl' and 'bulkData'.
%
% Syntax:
%	- Split the Nastran input file using the file path as the starting
%	  point:
%       >> filename = 'myTestFile.dat';
%       >> [ec, cc, bd, extra] = splitInputFile(filename)
%   - Split the Nastran input file by passing in the file contents:
%       >> filename      = 'myTestFile.dat';
%       >> file_contents = readCharDataFromFile(filename);
%       >> [ec, cc, bd, extra] = splitInputFile(file_contents);
%   - Using a log function to output diagnostics
%       >> log_fcn  = @(s) fprintf('%s\n', s)
%       >> filename = 'myTestFile.dat';
%       >> [ec, cc, bd, extra] = splitInputFile(filename, log_fcn)
%
% Detailed Description:
%	- 'execControl' and 'caseControl' are split by the keyword "CEND".
%   - 'caseControl' and 'bulkData' are split by the keyword "BEGIN BULK".
%
% See also: 
%
% References:
%	[1]. MSC.Nastran Getting Started User Guide
%
% Author    : Christopher Szczyglowski
% Email     : chris.szczyglowski@gmail.com
% Timestamp : 19-Apr-2020 15:09:54
%
% Copyright (c) 2020 Christopher Szczyglowski
% All Rights Reserved
%
%
% Revision: 1.0 19-Apr-2020 15:09:54
%	- Initial function:
%
% <end_of_pre_formatted_H1>

if nargin < 2
   logfcn = @(s) fprintf(''); %dummy function
end
if ischar(data) && exist(data, 'file') == 2 %Go from a file
    data = readCharDataFromFile(data);
end    
assert(iscellstr(data), 'Expected ''data'' to be a cell-array of strings.'); %#ok<ISCLSTR>

%Remove empty lines
%data = data(~cellfun(@(x) isempty(x), data));

%Logical indexing
idx_EC = contains(data, 'CEND');
idx_BD = contains(data, 'BEGIN BULK');

%Linear indexing
indEC = find(idx_EC == true);
indBD = find(idx_BD == true);

%Check for occurence of 'BEGIN BULK'
if ~any(idx_BD) %If not found, assume all is bulk
    execControl = {};
    caseControl = {};
    [bulkData, unresolvedBulk] = i_parseBulkData(data);
    logfcn(['Did not find tokens ''CEND'' or ''BEGIN BULK''. ', ...
        'Assuming all file contents are bulk data.']);
    return
end

%Grab the data
execControl = data(1 : indEC - 1);
caseControl = data(indEC + 1 : indBD - 1);
bulkData    = data(indBD + 1 : end);

%Remove "ENDDATA" from the BulkData cell array
bulkData(contains(bulkData, 'ENDDATA')) = [];

[bulkData, unresolvedBulk] = i_parseBulkData(bulkData);

logfcn(['Input data split into ''Executive Control'', ', ...
    '''Case Control'' and ''Bulk Data'' sections.']);

    function [bulkData, unresolvedBulk] = i_parseBulkData(bulkData)
        %i_parseBulkData Stashes any line that have less than 8 characters
        %in the variable 'unresolvedBulk' and retains only the lines that
        %have 8 characters or more.
        %
        % N.B. Any line that has less than 8 characters is likely to be a
        % system command.
        nChar = cellfun(@numel, bulkData);
        idx = and(nChar < 8, nChar > 1);
        unresolvedBulk = bulkData(idx);
        bulkData       = bulkData(~idx);        
    end

end


function propData = extractBulkData(cardData)
% EXTRACTBULKDATA extracts each column entry of each row of the input 'cardData'
% 
% 'cardData' is a cell array where each cell is the string from the row in
% the bulk data entry section of a bdf file.
% this function returns propData which is a cell array in which each cell
% is another cell array of each column entry for a given card, where the
% first cell is the card name.
% - continuations are compressed onto one line and all +/* characters are
% removed
% 
% Author: Fintan Healy
% Date: 16/03/2021
% email: fintan.healy@bristol.ac.uk
%
    % remove blank rows
    blnk_idx = cellfun(@(x)~isempty(x),regexp(cardData,'^[\s]*$','match'));
    cardData(blnk_idx) = [];
    propData = cell(size(cardData));
    
    % extract comma seperated rows
    comma_idx = contains(cardData,',');
    if any(comma_idx)
        propData(comma_idx) = regexp(cardData(comma_idx),'[^,]*','match');
    end
    %extract include cards
    include_idx = ~comma_idx & contains(cardData,'INCLUDE');
    if any(include_idx)
        propData(include_idx) = regexp(cardData(include_idx),'(.*) (.*)' ,'tokens','once');
    end
    % extract double precison cards
    long_idx = ~comma_idx & ~ include_idx & contains(cardData,'*');
    if any(long_idx)
        % split names
        expr = ['(.{0,8})',repmat('(.{0,16})',1,4)];
        propData(long_idx) = regexp(cardData(long_idx),expr,'tokens','once');
    end
    % extract cards in short form
    short_idx = ~(comma_idx|long_idx|include_idx);
    if any(short_idx)
        expr = repmat('(.{0,8})',1,9);
        propData(short_idx) = regexp(cardData(short_idx),expr,'tokens','once');
    end
    for i = 1:length(propData)
    % remove white space
       propData{i} = regexprep(propData{i},'\s','');
       % Check for scientific notation without 'E' e.g (-1.3-2) and replace with
       % standard form (-1.3E-2)
    end
    %flatten continuations
    cardRows = cellfun(@(x)isempty(x),regexp(cellfun(@(x)x{1},propData,'UniformOutput',false),'^[+\*]?'));
    cardInds = [find(cardRows);length(cardRows)+1];
    propData(~cardRows) = cellfun(@(x)x(2:end),propData(~cardRows),...
        'UniformOutput',false);
    tmp_data = {};
    for i = 1:length(cardInds)-1
        tmp_data{i} = horzcat(propData{cardInds(i):cardInds(i+1)-1});
    end
    propData = tmp_data;
    % remove stars
    for i = 1:length(propData)
        propData{i} = regexprep(propData{i},'[/*]$','');
    end
end