
%% get data
addpath('C:\Git\nastran_import_tool\f06')

% parameters
initial_fold_angle = 0;
flare_angle = 10;
origin = [0,1.00651180744171,0];

root_aoas = 2:0.5:15;
data = [];
wb = waitbar(0,'Calculating coast angles');
error_count = 0;
for a_i = 1:length(root_aoas)
    f = @(x)get_fold_angle([0,0,0],flare_angle,origin,root_aoas(a_i),x);
    data = [data,find_zero_fold_angle(f,root_aoas(a_i))]; 
end
close(wb)

%% extra functions

function idx = is_con(x)
    idx = 0;
    if ischar(x{1})
        if strcmp(x{1},'con')
            idx  = 1;
        end
    end
end

function data = find_zero_fold_angle(f,root_aoa,varargin)
    p = inputParser();
    p.addParameter('IC',[-90,0,0]);
    p.addParameter('MaxIter',50);
    p.parse(varargin{:});
    data = [];
    V_zero = fminbnd(@(x)f(x).^2,10,50,optimset('TolX',0.5));
    data(1).root_aoa = root_aoa;
    data(end).V = V_zero;    
end



function [res] = get_fold_angle(X,flare_angle,origin,root_aoa,V)
    fold_angle = X(1);
    twist_angle = X(2);
    % get trim data
    data = get_trim_data(fold_angle,twist_angle,flare_angle,origin,root_aoa,...
        V,'DragMoment',X(3),'TunnelWalls',true,...
        'fwt_cl_factor',1.25);
    
    %get fold angle
    res = get_fold_and_twist(data,fold_angle);
    res = res(1);
end

function res = get_fold_and_twist(data,fold_angle)
    twist_angle = rad2deg(data.thX(data.GP == 208));
    delta_fold = rad2deg(data.thX(data.GP == 209)) - twist_angle;
    fold_angle = fold_angle + delta_fold;
    res = [fold_angle,twist_angle];
end

