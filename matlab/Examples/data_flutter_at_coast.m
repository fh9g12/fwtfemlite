addpath('C:\Git\nastran_import_tool\f06')

% set fixed parameters
origin = [0,1.00651180744171,0];
flare_angle = 10;


% load coast data
load('coast_data_v10.mat')
idx = arrayfun(@is_con,{data.state});
con_data = data(idx);
flut_data = get_flutter_res(con_data,flare_angle,origin);
%% linear flutter data
% lin_flut_data = get_flutter_res(data([data.guess]==1),flare_angle,origin,'initial_fold');

%% get flutter data
save('coast_flut_data_v3.mat','flut_data');
%% plot the data
figure(2)
clf;
lineStyles = {'-','--','-.',':','-o'};
for a_i = 1:length(aoas)
    tmp_idx = [flut_data.root_aoa] == aoas(a_i);
    plotting.plot_flutter(flut_data(tmp_idx),0,1,2,lineStyles{a_i})
    get_flutter_speed(flut_data)
end
tmp_idx = [flut_data.root_aoa] == 0;
plotting.plot_flutter(flut_data(tmp_idx),0,1,2,lineStyles{a_i},repmat(0.3,2,3))
get_flutter_speed(flut_data)

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

function flut_data = modes2flut(mode_data)
    flut_data = [];
    for i = 1:length(mode_data)
       flut_data(i).MODE = mode_data(i).Mode;
       flut_data(i).M = 0;
       flut_data(i).RHO_RATIO = 1;
       flut_data(i).KF = NaN;
       flut_data(i).V = 0;
       flut_data(i).D = 0;
       flut_data(i).F = mode_data(i).cycles;
       flut_data(i).CMPLX = [0,sqrt(mode_data(i).eigenvalue)];
       flut_data(i).FOLD = mode_data(i).FOLD;
       flut_data(i).AoA = mode_data(i).AoA;
       flut_data(i).TWIST = mode_data(i).TWIST;
    end
end

function flut_data = get_flutter_res(data,flare_angle,origin,fold_field)
    aoas = unique([data.root_aoa]);
    flut_data = [];
    if ~exist('fold_field','var')
        fold_field = 'fold_angle';
    end
    for a_i = 1:length(aoas)
        % get all data points for each AoA
        a_idx = [data.root_aoa] == aoas(a_i);
        a_data = data(a_idx);
        % get all Velocities at this AoA
        Vs = unique([a_data.V]);
        for v_i = 1:length(Vs)
            %iterate through Velocities and get the flutter data at each point
            idx = find([a_data.V] == Vs(v_i),1);
            tmp_row = a_data(idx);
            if Vs(v_i)==0
                tmp_103_data = get_103_data(tmp_row.(fold_field),...
                    tmp_row.twist_angle,flare_angle,...
                    origin,aoas(a_i));
                tmp_flut_data = modes2flut(tmp_103_data);
            else
                tmp_flut_data = get_flutter_data(tmp_row.(fold_field),...
                    tmp_row.twist_angle,flare_angle,...
                    origin,aoas(a_i),Vs(v_i));
            end
            names = fieldnames(tmp_flut_data);
            for i = 1:length(tmp_flut_data)
                for j = 1:length(names)
                    tmp_row.(names{j}) = tmp_flut_data(i).(names{j});
                end
                flut_data = [flut_data,tmp_row];
            end
        end
    end
    %% complete mode tracking on each aoa
    for a_i = 1:length(aoas)
        tmp_idx = [flut_data.root_aoa] == aoas(a_i);
        flut_data(tmp_idx) = mode_tracking(flut_data(tmp_idx),2);
    end
end


