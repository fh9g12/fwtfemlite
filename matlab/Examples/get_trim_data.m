function data = get_trim_data(fold_angle,flare_angle,origin,root_aoa,V)
    trim_file = 'C:\Git\fwtfemlite\trim.bdf';
    % write the model 
    gen.write_WT_model(fold_angle,flare_angle,origin,root_aoa,false);

    %create trim cards
    gen.write_trim(trim_file,1,V,0);
    
    % delete old files
    delete('sol1*.*')

    % run NASTRAN
    fprintf('Computing sol144 for a fold: %.2f deg, flare: %.1f deg, root AoA: %.1f deg, and velocity %.1f m/s\n',...
        fold_angle,flare_angle,root_aoa,V);         
    command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol144.bdf',' 1>NUL 2>NUL'];
    system(command);
    
    %get Results
    data = mni.result.f06.read_f06_disp('','sol144');
end

