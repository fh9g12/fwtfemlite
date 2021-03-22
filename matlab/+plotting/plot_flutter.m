function plot_flutter(flut_data,Mach,Density_ratio,max_mode,varargin)
p = inputParser();
p.addParameter('LineStyle','-')
p.addParameter('DisplayName',[])
p.addParameter('LineWidth',1)
p.addParameter('Colors',[1,0,0;0,0,1;0,1,1;0,1,0;1,1,0;1,0,1])
p.parse(varargin{:})
% select only relevent modes
ind = ([flut_data.M]==Mach);
ind = ind & ([flut_data.RHO_RATIO] == Density_ratio);
ind = ind & ([flut_data.MODE] <= max_mode);

data = flut_data(ind);
for i = 1:max_mode
    mode_ind = [data.MODE] == i;
    mode_data = data(mode_ind);
    subplot(2,1,1)
    pl = plot([mode_data.V],[mode_data.F],p.Results.LineStyle);
    pl.Color = p.Results.Colors(i,:);
    pl.LineWidth = p.Results.LineWidth;
    if ~isempty(p.Results.DisplayName) && i==1
        pl.DisplayName = p.Results.DisplayName;
    else
        pl.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    hold on
    subplot(2,1,2)
    pl = plot([mode_data.V],[mode_data.D]*100,p.Results.LineStyle);
    pl.Color = p.Results.Colors(i,:);
    pl.LineWidth = p.Results.LineWidth;
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