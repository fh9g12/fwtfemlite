addpath('C:\Git\nastran_import_tool\f06')

% parameters
fold_angle = 10;
flare_angle = 10;
origin = [0,1.00651180744171,0];
root_aoa = 10;

flut_data = get_flutter_data(fold_angle,flare_angle,origin,10);

for i = 1:length(flut_data)
        flut_data(i).FOLD = fold_angle;
        flut_data(i).AoA = 0;     
end
figure(3)
clf;
plot_flutter(flut_data,0,1,3)
get_flutter_speed(flut_data)

function f_data = get_flutter_data(fold_angle,flare_angle,origin,root_aoa)
    flut_file = 'C:\Git\fwtfemlite\flutter.bdf';
    %create coords file
    fid = fopen('C:\Git\fwtfemlite\fwt_coord.bdf','w+');
    coords = fwt_coords(fold_angle,flare_angle,origin,root_aoa);
    coords.writeToFile(fid)
    fclose(fid);

    %create flutter points
    Vs = linspace(5,35,15);
    write_flutter(flut_file,1,0,Vs)
    
    % delete old files
    delete('sol1*.*')

    % run NASTRAN
    command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol145.bdf'];
    system(command);
    
    %plot Results
    f_data = read_f06_flutter('','sol145');
end

function fs = get_flutter_speed(flut_data)
    fs = inf;    
    for i = 1:2
        tmp_fs = find_crossing(flut_data(i).V,flut_data(i).D);
        if ~isnan(tmp_fs)
            if tmp_fs < fs
                fs = tmp_fs;
            end
        end     
    end
end

function x_cross = find_crossing(x,y)
    sign = y(1)/abs(y(1));
    x_cross = nan;
    for i = 2:length(x)
        if sign*y(i)<0
            m = (y(i)-y(i-1))/(x(i)-x(i-1));
            x_cross = x(i-1)-y(i-1)/m;
            break;
        end
    end
end
