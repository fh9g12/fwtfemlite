clear all
%%load data
load('coast_data.mat','data')


%% plot variation
root_aoas = unique([data.root_aoa]);
Vs = unique([data.V]);
figure(1)
clf;
colors = 'rbgckm';
for a_i = 1:length(root_aoas)
    idx = [data.root_aoa]==root_aoas(a_i);
    % plot linear coast angle
    tmp_idx = idx & [data.guess]==1;
    x = [data(tmp_idx).V];
    y = [data(tmp_idx).fold_angle];
    [~,i] = sort(x);
    
    p = plot(x(i),y(i),[colors(a_i),'--']);
    p.DisplayName = sprintf('%.0f degrees AoA',root_aoas(a_i));
    hold on
    % plot non-linear coast angle
    tmp_idx = idx & arrayfun(@is_con,{data.state});
    x = [data(tmp_idx).V];
    y = [data(tmp_idx).initial_fold];
    [~,i] = sort(x);
    p = plot(x(i),y(i),[colors(a_i),'-']);
    if ~isempty(p)
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
end
ylim([-120,80])
legend('location','southeast')
grid minor
xlabel('Velocity [m/s]')
ylabel('Coast Angle [deg]')

function idx = is_con(x)
    idx = 0;
    if ischar(x{1})
        if strcmp(x{1},'con')
            idx  = 1;
        end
    end
end