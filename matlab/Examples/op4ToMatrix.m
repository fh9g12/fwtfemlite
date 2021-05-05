function [matrix, varargout] = op4ToMatrix(filename, varargin)
%op4ToMatrix Returns a Matlab matrix based on the ASCII data in the .op4
%defined in 'filename'.

if nargin < 1
    [name, path] = uigetfile({'*.op4', 'OUTPUT4 File'}, 'Select an OUTPUT 4 file (.op4)');
    if isnumeric(name) || isnumeric(path)
        return
    end
    filename = fullfile(path, name);
end

%Parse inputs 
p = inputParser;
addRequired(p, 'filename', @ischar);
addOptional(p, 'matrixNames', [], @iscell);
parse(p, filename, varargin{:});

%Extract data from the .op4 file as raw text
data = extractDataFromFile(filename);
if isempty(data)
    error('File ''%s'' is empty. Unable to extract any data.', filename);
end

%Extract matrix header data
[nCol, nRow, name, maxEntryPerLine, numFormat] = extractHeaderData(data{1});
data  = data(2:end); %No longer need the header line!
nData = numel(data); 

%Preallocate matrix
matrix = zeros(nRow, nCol);

%Parse data and populate the matrix
isMatrixEnd = false;
index = 1;
while ~isMatrixEnd
    %Read entry
    headerData = sscanf(data{index}, '%f %f %f');
    colID  = headerData(1);
    rowID  = headerData(2);
    nEntry = headerData(3);    
    %How many lines of data need to be read?
    nLine  = ceil(nEntry/maxEntryPerLine);
    %Check index has not exceeded matrix size
    if colID > nCol || rowID > nRow
        %Update counter
        index = index + nLine + 1;
        %Check if we have exceeded the end of the data
        if index > nData
            isMatrixEnd = true;
        end
        continue
    end
    %Read data
    rowData = data(index+1 : index + nLine);
    rowData = sscanf(cat(2, rowData{:}), '%f');
    %Assign data to the matrix
    matrix(rowID : rowID + nEntry - 1,colID) = rowData;
    %Update counter
    index = index + nLine + 1;
    %Check if we have exceeded the end of the data
    if index > nData
        isMatrixEnd = true;
    end
end

if nargout > 1
   varargout{1} = [nRow, nCol]; 
end

end

function data = extractDataFromFile(filename)
%extractDataFromFile Extracts the data from the file 'filename' and returns
%the data as a cell array of strings.

%Get file identifier
fid = fopen(filename, 'r');
if fid == -1
    error('Unable to open file ''%s''.', filename);
end

%Import data as a cell array of strings
data = textscan(fid, '%s', ...
    'delimiter'    , '\n', ...
    'CommentStyle' , '$' , ...
    'whitespace'   , '');
data = data{:};

%Close file 
fclose(fid);

end

function [nCol, nRow, name, maxEntryPerLine, numFormat] = extractHeaderData(headerLine)
%extractHeaderData Extracts the meta data for the matrix from the header
%line (the first line) of the .op4 file.
%
% Meta data includes:
%   - The number of columns (nCol)
%   - The number of rows    (nRow)
%   - The name of the matrix (name)
%   - The max number of entries per line (maxEntryPerLine)
%   - The format spec for the matrix data as printed in the op4 (numFormat)

headerData = strsplit(headerLine); % -> split by blankspace

nCol = str2double(headerData{2});
nRow = str2double(headerData{3});

name = headerData{5};
name = name(isletter(name));

numFormat = strsplit(headerData{end}, ',');
numFormat = strsplit(numFormat{2}, 'E');

maxEntryPerLine = str2double(numFormat{1});

numFormat = ['%', numFormat{2}, 'e'];


end
