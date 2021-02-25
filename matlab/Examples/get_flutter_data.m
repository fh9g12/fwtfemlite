function f_data = get_flutter_data(fold_angle,flare_angle,origin,root_aoa,Vs)
    flut_file = 'C:\Git\fwtfemlite\flutter.bdf';
    % write the model 
    gen.write_WT_model(fold_angle,flare_angle,origin,root_aoa,true);

    %create flutter points
    gen.write_flutter(flut_file,1,0,Vs)
    
    % delete old files
    delete('sol1*.*')

    % run NASTRAN
    fprintf('Computing flutter data for a fold: %.2f deg, flare: %.1f deg, root AoA: %.1f deg, and %.0f velocities\n',...
        fold_angle,flare_angle,root_aoa,length(Vs));         
    command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol145.bdf',' 1>NUL 2>NUL'];
    system(command);
    
    %get Results
    f_data = mni.result.f06.read_f06_flutter('','sol145');
    
    % append fold angle and root AoA
    for j = 1:length(f_data)
            f_data(j).FOLD = fold_angle;
            f_data(j).AoA = root_aoa;     
    end
end

