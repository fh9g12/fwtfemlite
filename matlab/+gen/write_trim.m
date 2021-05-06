function write_trim(filename,rho,V,aoa)
    fid = fopen(filename,'w+');
    printing.bdf.writeFileStamp(fid);
    printing.bdf.writeComment('this file contain the trim card for a 144 solution',fid)
    printing.bdf.writeColumnDelimiter(fid,'8');
    
    t_card= cards.TRIM(1);
    t_card.Q = 0.5*rho*V^2;
    t_card.MACH = V/sqrt(1.4*286*293.15);
    t_card.ANGLEA = deg2rad(aoa);
    
    t_card.writeToFile(fid)
    fclose(fid);
end

