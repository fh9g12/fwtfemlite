addpath('C:\Git\nastran_import_tool\f06')

% set fixed parameters
origin = [0,1.00651180744171,0];
flare_angle = 10;

% load coast data
aoas = 0:2.5:10;
fold = -60:5:60;
Vs = [20];

wb = waitbar(0,'Calculating Pressure Distributions');
fold_data  = [];
for a_i = 1:length(aoas)
    a_wb = (a_i-1)/length(aoas);
    for f_i = 1:length(fold)
        f_wb = (f_i-1)/(length(aoas)*length(fold));
        for v_i = 1:length(Vs)
            v_wb = (v_i-1)/(length(Vs)*length(fold)*length(aoas));
            waitbar(a_wb+f_wb+v_wb,wb,'Calculating Pressure Distributions');
            [~,p_data,~] = get_trim_data(fold(f_i),...
                0,flare_angle,origin,aoas(a_i),Vs(v_i),...
                'Locked',true);
            res.root_aoa = aoas(a_i);
            res.fold_angle = fold(f_i);
            res.V = Vs(v_i);
            res.p_data = p_data;
            fold_data = [fold_data,res];
        end
    end
end
save('fold_cp_data.mat','fold_data')