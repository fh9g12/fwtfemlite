function data = get_101_data(fold_angle,twist_angle,flare_angle,...
    origin,root_aoa,locked)
    model_dir = 'C:\Git\fwtfemlite\';
    % write the model 
    wt_model = gen.WT_model(fold_angle,twist_angle,flare_angle,origin,root_aoa);
    wt_model.Locked = locked;
    wt_model.writeToFile(model_dir,'GravStiffness',true)
    
    % delete old files
    delete('sol1*.*')

    % run NASTRAN
    fprintf('Computing sol101 for a fold: %.2f deg, flare: %.1f deg, root AoA: %.1f deg\n',...
        fold_angle,flare_angle,root_aoa);         
    command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol101.bdf',' 1>NUL 2>NUL'];
    system(command);
    
    %get Results
    data = mni.result.f06('sol101.f06').read_disp();
end

