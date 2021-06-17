clear all
%%load data
load('coast_data_v2.mat','data')


%% plot variation
root_aoas = unique([data.root_aoa]);
Vs = unique([data.V]);
figure(1)
clf;
colors = 'rbgckm';
p= plot([0],[0],'-','color',[1,1,1],'DisplayName',...
    '\bf   Hue');
hold on
for a_i = 1:length(root_aoas)
    idx = [data.root_aoa]==root_aoas(a_i);
    % plot linear coast angle
    tmp_idx = idx & [data.guess]==1;
    x = [data(tmp_idx).V];
    y = [data(tmp_idx).fold_angle];
    [~,i] = sort(x);
    
    p = plot(x(i),y(i),[colors(a_i),'--']);
    p.LineWidth = 2;
    if ~isempty(p)
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end       
    % plot non-linear coast angle
    tmp_idx = idx & arrayfun(@is_con,{data.state});
    x = [data(tmp_idx).V];
    y = [data(tmp_idx).initial_fold];
    [~,i] = sort(x);
    p = plot(x(i),y(i),[colors(a_i),'-']);
    p.DisplayName = sprintf('%.0f degrees AoA',root_aoas(a_i));
    p.LineWidth = 2;
end
ylim([-120,80])
legend('location','southeast')
grid minor
xlabel('Velocity [m/s]')
ylabel('Coast Angle [deg]')

p= plot([0],[0],'-','color',[1,1,1],'DisplayName',...
    '\bf   Line Styles');

p= plot([0],[0],'-','color',[0.4,0.4,0.4],'DisplayName',...
    'Linearised about the coast angle');
p= plot([0],[0],'--','color',[0.6,0.6,0.6],'DisplayName',...
    'Linearised about the zero fold angle');

function idx = is_con(x)
    idx = 0;
    if ischar(x{1})
        if strcmp(x{1},'con')
            idx  = 1;
        end
    end
end