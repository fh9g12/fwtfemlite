function writeComment(str, fid)
    %writeComment Write a comment with data 'str' into the file
    %with identifier 'fid'. The comment will be split over multiple
    %lines so that it conforms to the 80 character width of
    %MSC.Nastran bulk data files.
    width = 80;

    % ensure str ends with a space character for indexing
    if str(end) ~= ' '
        str = [str,' '];
    end
    % find all spaces and put the first word in string list
    idx = find(str == ' ');
    strs = [{['$ ',str(1:idx(1)-1)]},];

    for i = 2:length(idx)
        delta = (idx(i)-idx(i-1));
        if length(strs{end})+delta > width
            strs{end+1} = ['$ ',str(idx(i-1)+1:idx(i)-1)];
        else
            strs{end} = [strs{end},' ',str(idx(i-1)+1:idx(i)-1)];
        end
    end
    final_str = [strjoin(strs,'\r\n'),'\r\n'];
    for i = 1:length(strs)
        fprintf(fid,[strs{i},'\r\n']); 
    end              
end

