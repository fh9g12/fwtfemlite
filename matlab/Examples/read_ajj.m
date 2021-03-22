file = 'C:\Git\fwtfemlite\matlab\sol144.f06';

FID = fopen(obj.filepath,'r');
readingFlag = 0;
ii = 0;

while feof(FID)~= 1
    f06Line = fgets(FID);
    if contains(f06Line,'MATRIX AJJ')
        readingFlag = 1;
    end
end