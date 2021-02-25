function plot_flutter(flut_data,Mach,Density_ratio,max_mode,varargin)
p = inputParser();
p.addParameter('LineStyle','-')
p.addParameter('DisplayName',[])
p.parse(varargin{:})
% select only relevent modes
ind = ([flut_data.M]==Mach);
ind = ind & ([flut_data.RHO_RATIO] == Density_ratio);
ind = ind & ([flut_data.MODE] <= max_mode);

colors = 'rbcgym';
data = flut_data(ind);
for i = 1:max_mode
    mode_ind = [data.MODE] == i;
    mode_data = data(mode_ind);
    subplot(2,1,1)
    pl = plot([mode_data.V],[mode_data.F],[colors(i),p.Results.LineStyle]);
    if ~isempty(p.Results.DisplayName) && i==1
        pl.DisplayName = p.Results.DisplayName;
    else
        pl.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    hold on
    subplot(2,1,2)
    pl = plot([mode_data.V],[mode_data.D],[colors(i),p.Results.LineStyle]);
    if ~isempty(p.Results.DisplayName) && i==1
        pl.DisplayName = p.Results.DisplayName;
    else
        pl.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    hold on
end

subplot(2,1,1)
grid minor
xlabel('Velocity [m/s]')
ylabel('Frequency [Hz]')
title('Vf Diagram')
subplot(2,1,2)
grid minor
xlabel('Velocity [m/s]')
ylabel('Damping')
title('Vg Diagram')
end