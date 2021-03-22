addpath('C:\Git\nastran_import_tool\f06')

% set fixed parameters
origin = [0,1.00651180744171,0];
flare_angle = 10;

% load coast data
load('coast_flut_data.mat','flut_data');
aoas = unique([flut_data.root_aoa]);

%% get the pressure data
wb = waitbar(0,'calc pressure data');
aoas = unique([flut_data.root_aoa]);
Vs = unique([flut_data.V]);
for a_i = 1:length(aoas)
    idx = [flut_data.root_aoa]==aoas(a_i);
    for v_i = 1:length(Vs)
        if Vs(v_i) == 0
            continue
        end
        waitbar(((a_i-1)*length(aoas) + v_i)/(length(aoas)*length(Vs)),...
            wb,'calc pressure data')
        tmp_idx = idx & [flut_data.V]==Vs(v_i);
        tmp_data = flut_data(tmp_idx);
        [~,p_data,~] = get_trim_data(tmp_data(1).fold_angle,...
                tmp_data(1).twist_angle,flare_angle,origin,...
                tmp_data(1).root_aoa,tmp_data(1).V);
        [flut_data(tmp_idx).p_data] = deal(p_data);      
    end
end
close(wb)
save('coast_flut_data_v2.mat','flut_data');