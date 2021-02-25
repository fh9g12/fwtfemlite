addpath('C:\Git\nastran_import_tool\f06')

% parameters
fold_angles = -45:5:45;
root_aoas = [0,5,10];
flare_angle = 10;
origin = [0,1.00651180744171,0];
Vs=2:2:40;

data = zeros(length(fold_angles),2);
figure(3)
clf;
for i = 1:length(fold_angles)
    data(i,1) = fold_angles(i);
    for j = 1:length(root_aoas)
        flut_data = get_flutter_data(fold_angles(i),...
            flare_angle,origin,root_aoas(j),Vs);
        data(i,j+1) = get_flutter_speed(flut_data);
%         for k = 1:length(flut_data)
%             flut_data(k).FOLD = fold_angles(i);
%             flut_data(k).AoA = 0;     
%         end
%         figure(3)
         plotting.plot_flutter(flut_data,0,1,3)
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
