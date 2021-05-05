addpath('C:\Git\nastran_import_tool\f06')

% set fixed parameters
origin = [0,1.00651180744171,0];
flare_angle = 10;


% load coast data
load('coast_flut_data_v3.mat','flut_data');
load('coast_lin_flut_data_v2.mat','lin_flut_data');
aoas = unique([flut_data.root_aoa]);

%% fix modes
manual_switch = {...
    {12.59,{20,fliplr(eye(2))}},...
    {10.09,{22,fliplr(eye(2))}},...
    };
switch_aoa = cellfun(@(x)x{1},manual_switch);
for a_i = 1:length(aoas)
    idx = find(switch_aoa==aoas(a_i),1);
    if ~isempty(idx)
        ms = manual_switch{idx}(2);
    else
        ms = {};
    end
    tmp_idx = [flut_data.root_aoa] == aoas(a_i);
    flut_data(tmp_idx) = mode_tracking(flut_data(tmp_idx),2,...
        'manual_switch',ms);
end
save('coast_flut_data_v3.mat','flut_data')

%% plot the data
figure(1)
clf;

% plot linear results
tmp_idx = unique([lin_flut_data.root_aoa]);
plotting.plot_flutter(lin_flut_data([lin_flut_data.root_aoa]==tmp_idx(1)),0,1,2,'LineStyle','-',...
    'Colors',repmat([0.1,0.3,0.2],2,1),...
    'DisplayName','Linear Model','LineWidth',2)

lineStyles = {'-','--','-.',':','-o'};
for a_i = 1:length(aoas)
    tmp_idx = [flut_data.root_aoa] == aoas(a_i);
    plotting.plot_flutter(flut_data(tmp_idx),0,1,2,...
        'LineStyle',lineStyles{a_i},...
        'DisplayName',sprintf('%.1f AoA',aoas(a_i)),...
        'LineWidth',1.5)
    get_flutter_speed(flut_data);
end

% parameters
subplot(2,1,1)
legend('location','southeast')
grid minor
grid minor
subplot(2,1,2)
ylim([-50, 50])
grid minor
grid minor




%% functions
function fs = get_flutter_speed(flut_data)
    fs = inf;    
    for i = 1:2
        tmp_fs = find_crossing(flut_data(i).V,flut_data(i).D);
        if ~isnan(tmp_fs)
            if tmp_fs < fs
                fs = tmp_fs;
            end
        end     
    end
end

function x_cross = find_crossing(x,y)
    sign = y(1)/abs(y(1));
    x_cross = nan;
    for i = 2:length(x)
        if sign*y(i)<0
            m = (y(i)-y(i-1))/(x(i)-x(i-1));
            x_cross = x(i-1)-y(i-1)/m;
            break;
        end
    end
end
