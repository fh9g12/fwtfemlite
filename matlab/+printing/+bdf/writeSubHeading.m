function writeSubHeading(fid, text)
    %writeSubHeading : Writes the 'text' in the FEMAP subheading
    %style            

    fprintf(fid, ['$ ' repmat('-', [1, 78]) '\n']);
    fprintf(fid, sprintf('$ %s\n', text));
    fprintf(fid, ['$ ' repmat('-', [1, 78]) '\n']);

end

