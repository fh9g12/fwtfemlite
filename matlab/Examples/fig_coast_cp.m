addpath('C:\Git\nastran_import_tool\f06')

% set fixed parameters
origin = [0,1.00651180744171,0];
flare_angle = 10;

% load coast data
load('coast_flut_data_v2.mat','flut_data');
aoas = unique([flut_data.root_aoa]);
flut_data = get_eff_mom_arm(flut_data);
%% plot it
aoa = 7.5;
V_ref = 20;
[~,ref_p,~] = get_trim_data(0,0,flare_angle,origin,aoa,V_ref,'Locked',true);

a_i = find(aoas==aoa);

ind = ([flut_data.M]==0);
ind = ind & ([flut_data.RHO_RATIO] == 1);
ind = ind & ([flut_data.MODE] == 1);
ind = ind & [flut_data.root_aoa] == aoas(a_i);
ind = ind & [flut_data.V] > 0;
data = flut_data(ind);
figure(3)
clf;
shade = fliplr((1:length(data))/length(data)*0.8);
max_val = 0;
for i = 1:length(data)
    cp = [mean(reshape(data(i).p_data.Cp,10,55)),0];
    max_val = max([max_val,cp]);
    p = plot(([1:55,55.5])/55.5,[cp]);
    p.Color = [shade(i),shade(i),1];   
    p.LineWidth = 2.5;
    if mod(data(i).V,10)==0
        p.DisplayName = sprintf('V: %.0f m/s',data(i).V);
    else
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    hold on
    p = plot(data(i).eff_mom_arm(1),data(i).eff_mom_arm(2),'o');
    p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    p.Color = [0 0 0];
    p.MarkerFaceColor = [0 0 0];
    p.MarkerSize = 5;
end
p = plot([40.5,40.5]/55.5,[0,max_val*1.05],'--','Color',[0.3,0.3,0.3]);
p.DisplayName = 'Hinge Line';

p = plot(([1:55,55.5])/55.5,[ref_p.Cp(1:10:length(ref_p.Cp)),0]);
p.Color = [1 0 0];
p.LineWidth = 2;
p.DisplayName = sprintf('Fixed Wing, V: %.1f m/s, AoA %.0f deg',V_ref,aoa);

ylim([0,max_val*1.05])
legend('Location','southwest')
title('Variation in the pressure distributuion of the NASTRAN model at differnt velocities')

function data = get_eff_mom_arm(data)
    for i = 1:length(data)
        if isempty(data(i).p_data)
            continue
        end
        % calc cp's
        cp = [mean(reshape(data(i).p_data.Cp,10,55)),0];
        eta = [0.5:54.5,55]/55;

        % calc moment about hinge
        F = sum(cp(end-14:end));
        M = sum((eta(end-14:end)-40/55).*cp(end-14:end));

        % calc effective moemnt arm
        eff_mom_arm = M/F + 40/55;
        eff_y = interp1(eta,cp,eff_mom_arm);
        data(i).eff_mom_arm = [eff_mom_arm,eff_y];
    end
end
