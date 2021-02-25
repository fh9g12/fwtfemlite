
addpath('C:\Git\nastran_import_tool\f06')

% parameters
flare_angle = 10;
origin = [0,1.00651180744171,0];
root_aoa = 10;
V = 15;


%% compute predicted fold angles
fold_angles = -1*[30:0.5:50];
res = zeros(size(fold_angles));
for a_i = 1:length(fold_angles)
    flut_data = get_trim_data(fold_angles(a_i),flare_angle,origin,root_aoa,V);
    res(a_i) = rad2deg(flut_data.thX(flut_data.GP == 209)-flut_data.thX(flut_data.GP == 208));   
end
%% plot
figure(1)
clf;
plot(fold_angles,res)
xlabel('deformed fold angle [deg]')
ylabel('predicted deflection from deformed shape [deg]')
title (sprintf('Problem stiffness at 1 m/s and a root AoA of 0'))
