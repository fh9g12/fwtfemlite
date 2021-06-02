function write_trim(filename,rho,V,aoa)
    fid = fopen(filename,'w+');
    mni.printing.bdf.writeFileStamp(fid);
    mni.printing.bdf.writeComment('this file contain the trim card for a 144 solution',fid)
    mni.printing.bdf.writeColumnDelimiter(fid,'8');
    
    Mach = V/sqrt(1.4*286*293.15);
    trimParams = gen.TrimParameters.Locked(V,rho,Mach);
    trimParams.ANGLEA.Value = deg2rad(aoa);
    
    % create aestat cards
    param_names = fieldnames(trimParams);
    
    for i = 1:length(param_names)
        obj = trimParams.(param_names{i});
        if isa(obj,'gen.TrimParameter')
            if strcmp(obj.Type,'Rigid Body')
                mni.printing.cards.AESTAT(i,obj.Name).writeToFile(fid);
            end
        end    
    end    
    % set trim values (NAN is free and will not be included in trim card)
    labels = [];
    for i = 1:length(param_names)
        obj = trimParams.(param_names{i});
        if isa(obj,'gen.TrimParameter')
            if ~isnan(obj.Value)
                labels = [labels,{obj.Name},{obj.Value}];
            end
        end    
    end
    
    % write trim card
    Q = 0.5*trimParams.rho*trimParams.V^2;
    t_card= mni.printing.cards.TRIM(1,trimParams.Mach,Q,labels(:));    
    t_card.writeToFile(fid)
    fclose(fid);
end

