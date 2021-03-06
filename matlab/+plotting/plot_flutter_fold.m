function plot_flutter(flut_data,Mach,Density_ratio,max_mode,lineStyle)
% select only relevent modes
ind = ([flut_data.M]==Mach);
ind = ind & ([flut_data.RHO_RATIO] == Density_ratio);
ind = ind & ([flut_data.MODE] <= max_mode);

colors = 'rbcgym';
data = flut_data(ind);
if ~exist('lineStyle')
    lineStyle = '-';
end
for i = 1:max_mode
    mode_ind = [data.MODE] == i;
    mode_data = data(mode_ind);
    subplot(3,1,1)
    p = plot([mode_data.V],[mode_data.F],[colors(i),lineStyle]);
    hold on
    subplot(3,1,2)
    p = plot([mode_data.V],[mode_data.D],[colors(i),lineStyle]);
    hold on
    if i ==1
        subplot(3,1,3)
        p = plot([mode_data.V],[mode_data.FOLD],[colors(i),lineStyle]);
        hold on
    end
end

subplot(3,1,1)
grid minor
xlabel('Velocity [m/s]')
ylabel('Frequency [Hz]')
title('Vf Diagram')
subplot(3,1,2)
grid minor
xlabel('Velocity [m/s]')
ylabel('Damping')
title('Vg Diagram')
subplot(3,1,3)
grid minor
xlabel('Velocity [m/s]')
ylabel('Fold Angle [deg]')
end