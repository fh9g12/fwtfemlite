addpath('C:\Git\nastran_import_tool\f06')

% parameters
fold_angle = 0;
flare_angle = 10;
origin = [0,1.00651180744171,0];


styles = {'-','--','-.'};
root_aoas = 0:5:10;
data = zeros(length(root_aoas),2);
Vs=2:2:40;

figure(1)
clf;
hold on
for i = 1:length(root_aoas)
    root_aoa = root_aoas(i);

    flut_data = get_flutter_data(fold_angle,flare_angle,origin,root_aoa,Vs);
    
    plot_flutter(flut_data,0,1,3,styles{i})
    data(i,:) = [root_aoa,get_flutter_speed(flut_data)];
    
end
subplot(2,1,1)
subplot(2,1,2)
ylim([-1, 1])

figure(2)
clf;
plot(data(:,1),data(:,2),'o-')
ylabel('Linear Fluuter Speed [m/s]')
xlabel('Root Angle of Attack [deg] ')
