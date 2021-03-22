function f_data = get_103_data(fold_angle,twist_angle,flare_angle,...
    origin,root_aoa,locked)
    model_dir = 'C:\Git\fwtfemlite\';
    % write the model 
    wt_model = gen.WT_model(fold_angle,twist_angle,flare_angle,origin,root_aoa);
    wt_model.Locked = locked;
    wt_model.writeToFile(model_dir,'GravStiffness',true)
    
    % delete old files
    delete('sol1*.*')

    % run NASTRAN
    fprintf('Computing sol103 for a fold: %.2f deg, flare: %.1f deg, root AoA: %.1f deg\n',...
        fold_angle,flare_angle,root_aoa);         
    command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol103.bdf',' 1>NUL 2>NUL'];
    system(command);
    
    %get Results
    f_data = mni.result.f06('sol103.f06').read_modes();
    
    % append fold angle and root AoA
    for j = 1:length(f_data)
            f_data(j).FOLD = fold_angle;
            f_data(j).TWIST = twist_angle;
            f_data(j).AoA = root_aoa;     
    end
end

