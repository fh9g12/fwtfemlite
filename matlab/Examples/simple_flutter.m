addpath('C:\Git\nastran_import_tool\f06')

% parameters
fold_angles = -45:5:45;
root_aoas = [0,5,10];
flare_angle = 10;
origin = [0,1.00651180744171,0];

data = zeros(length(fold_angles),2);
figure(3)
clf;
for i = 1:length(fold_angles)
    data(i,1) = fold_angles(i);
    for j = 1:length(root_aoas)
        flut_data = get_flutter_data(fold_angles(i),...
            flare_angle,origin,root_aoas(j));
        data(i,j+1) = get_flutter_speed(flut_data);
%         for k = 1:length(flut_data)
%             flut_data(k).FOLD = fold_angles(i);
%             flut_data(k).AoA = 0;     
%         end
%         figure(3)
%         plot_flutter(flut_data,0,1,3)
    end
end
figure(1)
clf;
for i = 1:3
    plot(data(:,1),data(:,i+1),'-o')
    hold on
end
xlabel('Fold Angle [deg]')
ylabel('Linear Flutter speed [m/s]')
grid minor
legend('0 degrees root aoa','5 degrees root aoa','10 degrees root aoa')

function f_data = get_flutter_data(fold_angle,flare_angle,origin,root_aoa)
    flut_file = 'C:\Git\fwtfemlite\flutter.bdf';
    %create coords file
    fid = fopen('C:\Git\fwtfemlite\fwt_coord.bdf','w+');
    coords = fwt_coords(fold_angle,flare_angle,origin,root_aoa);
    coords.writeToFile(fid)
    fclose(fid);

    %create flutter points
    Vs = 5:2.5:60;
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
