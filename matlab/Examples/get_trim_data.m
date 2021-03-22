function [data,p_data,f_data] = get_trim_data(fold_angle,twist_angle,...
    flare_angle,origin,root_aoa,V,varargin)
    p=inputParser();
    p.addParameter('Locked',false);
    p.parse(varargin{:});
    model_dir = 'C:\Git\fwtfemlite\';
    % write the model 
    wt_model = gen.WT_model(fold_angle,twist_angle,flare_angle,origin,root_aoa);
    wt_model.Locked = p.Results.Locked;
    wt_model.writeToFile(model_dir,'GravStiffness',true)

    %create trim cards
    gen.write_trim([model_dir,'trim.bdf'],1,V,0);
    
    % delete old files
    delete('sol1*.*')

    % run NASTRAN
    fprintf('Computing sol144 for a fold: %.2f deg, flare: %.1f deg, root AoA: %.1f deg, and velocity %.1f m/s\n',...
        fold_angle,flare_angle,root_aoa,V);         
    command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol144.bdf',' 1>NUL 2>NUL'];
    system(command);
    
    %get Results
    data_file = mni.result.f06('sol144.f06');
    
    data = data_file.read_disp;
    p_data = data_file.read_aeroP;
    f_data = data_file.read_aeroF;
end

