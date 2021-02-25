addpath('C:\Git\nastran_import_tool\f06')

% parameters
fold_angle = 40;
flare_angle = 10;
origin = [0,1.00651180744171,0];
root_aoa = 0;

flut_data = get_mode_data(fold_angle,flare_angle,origin,5);

function f_data = get_mode_data(fold_angle,flare_angle,origin,root_aoa)
    fid = fopen('C:\Git\fwtfemlite\fwt_coord.bdf','w+');
    coords = fwt_coords(fold_angle,flare_angle,origin,root_aoa);
    coords.writeToFile(fid)
    K = 0.904*sind(-fold_angle);
    if abs(K)<1e-4
        K=1e-4;
    end
    
    write_hinge('C:\Git\fwtfemlite\hinge.bdf',K)
    fclose(fid);
    
    % delete old files
    delete('sol1*.*')

    % run NASTRAN
    command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol103.bdf'];
    system(command);
    
    %plot Results
    f_data = mni.result.f06.read_f06_extract_modeshapes('','sol103');
end