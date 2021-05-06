function write_flutter(filename,Dens,Mach,Vs)
    fid = fopen(filename,'w+');
    printing.bdf.writeFileStamp(fid);
    printing.bdf.writeComment('this file contain the flutter cards for a 145 solution',fid)
    printing.bdf.writeColumnDelimiter(fid,'8');

    fl_cards = [{cards.FLFACT(1,Dens)},{cards.FLFACT(2,Mach)},{cards.FLFACT(3,Vs)}];    
    for i = 1:length(fl_cards)
        fl_cards{i}.writeToFile(fid)
    end
    
    printing.bdf.writeColumnDelimiter(fid,'8');
    f_card = cards.FLUTTER(4,'PK',1,2,3,6);
    f_card.writeToFile(fid)
    fclose(fid);
end

