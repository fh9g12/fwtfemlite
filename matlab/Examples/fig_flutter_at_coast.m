addpath('C:\Git\nastran_import_tool\f06')

% set fixed parameters
origin = [0,1.00651180744171,0];
flare_angle = 10;


% load coast data
load('coast_flut_data.mat','flut_data');
aoas = unique([flut_data.root_aoa]);
%% plot the data
figure(2)
clf;
lineStyles = {'-','--','-.',':','-o'};
for a_i = 1:length(aoas)
    tmp_idx = [flut_data.root_aoa] == aoas(a_i);
    plotting.plot_flutter(mode_tracking(flut_data(tmp_idx),2),0,1,2,...
        'LineStyle',lineStyles{a_i},'DisplayName',sprintf('%.1f AoA',aoas(a_i)))
    get_flutter_speed(flut_data);
end
% parameters
subplot(2,1,1)
legend('location','southeast')
%grid minor
subplot(2,1,2)
ylim([-1, 1])
%grid minor

%% functions
function idx = is_con(x)
    idx = false;
    if ischar(x{1}) && strcmp(x{1},'con')
            idx  = true;
    end
end

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
