%% parameters
twist_angle = 0;
flare_angle = 10;
origin = [0,1.00651180744171,0];

load('fold_cp_data.mat','fold_data')

fold_data = get_eff_mom_arm(fold_data);

aoa = 10;
V = 20;
folds = -60:5:60;
shades = linspace(0.8,0,length(folds));

idx = [fold_data.root_aoa]==aoa;
idx = idx & [fold_data.V]==V;
data = fold_data(idx);

figure(2)
clf;
cp_range = [0,0];
for i = 1:length(folds)
    tmp_idx = find([data.fold_angle]==folds(i),1);
    % calc cp's
    cp = [mean(reshape(data(tmp_idx).p_data.Cp,10,55)),0];
    cp_range = [min([cp_range,cp]),max([cp_range,cp])];
    eta = [0.5:54.5,55]/55; 
    
    p = plot(eta,cp,'Color',[shades(i),shades(i),1]);
    p.LineWidth = 2;
    if mod(folds(i),30)==0
        p.DisplayName = sprintf('Fold Angle: %.0f deg',folds(i));
    else
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    hold on;
    
    p = plot(data(i).eff_mom_arm(1),data(i).eff_mom_arm(2),'o');
    p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    p.Color = [0 0 0];
    p.MarkerFaceColor = [0 0 0];
    p.MarkerSize = 5;
    
end
p = plot([40.5,40.5]/55.5,cp_range*1.05,'--','Color',[0.3,0.3,0.3]);
p.DisplayName = 'Hinge Line';

p=plot([0],[cp_range(1)*2],'ko','MarkerFaceColor','k');
p.DisplayName = 'Effective Moment Arm';
legend('Location','southwest')
ylim(cp_range*1.1)


function data = get_eff_mom_arm(data)
    for i = 1:length(data)
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



