addpath('C:\Git\nastran_import_tool\f06')

% set fixed parameters
origin = [0,1.00651180744171,0];
flare_angle = 10;


% load coast data
load('coast_data.mat')
idx = arrayfun(@is_con,{data.state});
con_data = data(idx);

%% get flutter data
%for each root AoA and Velocity get the flutter data
aoas = unique([con_data.root_aoa]);
flut_data = [];
for a_i = 1:length(aoas)
    % get all data points for each AoA
    a_idx = [con_data.root_aoa] == aoas(a_i);
    a_data = con_data(a_idx);
    % get all Velocities at this AoA
    Vs = unique([a_data.V]);
    for v_i = 1:length(Vs)
        %iterate through Velocities and get the flutter data at each point
        idx = find([a_data.V] == Vs(v_i),1);
        tmp_row = a_data(idx);
        fold_angle = tmp_row.initial_fold;
        tmp_flut_data = get_flutter_data(fold_angle,flare_angle,...
            origin,aoas(a_i),Vs(v_i));
        names = fieldnames(tmp_flut_data);
        for i = 1:length(tmp_flut_data)
            for j = 1:length(names)
                tmp_row.(names{j}) = tmp_flut_data(i).(names{j});
            end
            flut_data = [flut_data,tmp_row];
        end
    end
end
% save('coast_flut_data.mat','flut_data');
%% plot the data
figure(2)
clf;
lineStyles = {'-','--','-.',':','-o'};
for a_i = 1:length(aoas)
    tmp_idx = [flut_data.root_aoa] == aoas(a_i);
    plotting.plot_flutter(flut_data(tmp_idx),0,1,2,lineStyles{a_i})
    get_flutter_speed(flut_data)
end
% parameters
subplot(2,1,1)
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
