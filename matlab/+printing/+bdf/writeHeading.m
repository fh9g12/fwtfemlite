function writeHeading(fid, text)
    %writeHeading Writes the 'text' in FEMAP heading style.

    fprintf(fid, '$\n');
    fprintf(fid, '$ %s\n', text);
    fprintf(fid, ['$ ' repmat('*', [1, 78]) '\n']);

end

