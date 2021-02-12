function write_flutter(filename,Dens,Mach,Vs)

    fid = fopen(filename,'w+');
    awi.fe.FEBaseClass.writeFileStamp(fid);
    awi.fe.FEBaseClass.writeComment('this file contain the flutter cards for a 145 solution',fid)
    awi.fe.FEBaseClass.writeColumnDelimiter(fid,'8');

    fl_cards = [{cards.FLFACT(1,Dens)},{cards.FLFACT(2,Mach)},{cards.FLFACT(3,Vs)}];    
    for i = 1:length(fl_cards)
        fl_cards{i}.writeToFile(fid)
    end
    
    awi.fe.FEBaseClass.writeColumnDelimiter(fid,'8');
    f_card = cards.Flutter(4,'PK',1,2,3,6);
    f_card.writeToFile(fid)
    fclose(fid);
end

