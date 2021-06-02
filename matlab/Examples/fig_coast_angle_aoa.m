clear all
%%load data
load('coast_data_aoa.mat','data')


%% plot variation
root_aoas = unique([data.root_aoa]);
Vs = unique([data.V]);
Vs = Vs(Vs~=35);
Vs = Vs(Vs~=25);
figure(1)
clf;
colors = 'rbgkm';
p= plot([0],[0],'-','color',[1,1,1],'DisplayName',...
    '\bf   Hue');
hold on
for v_i = 1:length(Vs)
    idx = [data.V]==Vs(v_i);
    % plot linear coast angle
    tmp_idx = idx & [data.guess]==1;
    x = [data(tmp_idx).root_aoa];
    y = [data(tmp_idx).fold_angle];
    [~,i] = sort(x);
    
    p = plot(x(i),y(i),[colors(v_i),':']);
    p.LineWidth = 2;
    if ~isempty(p)
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end    
    % plot non-linear coast angle
    tmp_idx = idx & arrayfun(@is_con,{data.state});
    x = [data(tmp_idx).root_aoa];
    y = [data(tmp_idx).initial_fold];
    [~,i] = sort(x);
    p = plot(x(i),y(i),[colors(v_i),'-']);
    p.DisplayName = sprintf('%.1f m/s',Vs(v_i));
    p.LineWidth = 2;
end
ylim([-120,80])
leg = legend('location','southeast');
leg.NumColumns = 2;
leg.ItemTokenSize = ones(1,2)*20;
grid minor
xlabel('Root Angle of Attack [deg]')
ylabel('Coast Angle [deg]')
p= plot([0],[0],'-','color',[1,1,1],'DisplayName',...
    '\bf   Wing Model');

p= plot([0],[0],'-','color',[0.4,0.4,0.4],'DisplayName',...
    'Baseline','LineWidth',2);
p= plot([0],[0],':','color',[0.6,0.6,0.6],'DisplayName',...
    'LACA','LineWidth',2);

function idx = is_con(x)
    idx = 0;
    if ischar(x{1})
        if strcmp(x{1},'con')
            idx  = 1;
        end
    end
end