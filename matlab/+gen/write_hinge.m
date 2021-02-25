function write_hinge(filename,varargin)
    p = inputParser();
    p.addOptional('hingeStiffness',1e-4)
    p.parse(varargin{:})

    fid = fopen(filename,'w+');
    awi.fe.FEBaseClass.writeFileStamp(fid);
    awi.fe.FEBaseClass.writeComment('this file contains the Hinge data for teh FWT WT Model',fid)
    awi.fe.FEBaseClass.writeColumnDelimiter(fid,'8');
    fl_cards = [{cards.Grid(208,[0,0,0],'CP',3,'CD',3)},...
        {cards.Grid(209,[0,0,0],'CP',3,'CD',3)},...
        {cards.RJoint(251,208,209,'CB','12356')},...
        {cards.CBush(103,13,208,209,'CID',3)},...
        {cards.PBush(13,'K',[0,0,0,p.Results.hingeStiffness,0,0])}];
    for i = 1:length(fl_cards)
        fl_cards{i}.writeToFile(fid)
    end
    fclose(fid);
end

