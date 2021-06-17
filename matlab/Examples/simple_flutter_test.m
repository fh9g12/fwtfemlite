% parameters
fold_angle = 0;
flare_angle = 10;
origin = [0,1.00651180744171,0];
Vs=2:2:40;
figure(1)
clf;
hold on
styles = {'-','--','-.'};
root_aoas = [0,5,10];
for i = 1:length(root_aoas)
    root_aoa = root_aoas(i);
    flut_data = get_flutter_data(fold_angle,flare_angle,origin,root_aoa,Vs);    
    plotting.plot_flutter(flut_data,0,1,3,styles{i})
    get_flutter_speed(flut_data); 
end
subplot(2,1,1)
subplot(2,1,2)
ylim([-1, 1])
