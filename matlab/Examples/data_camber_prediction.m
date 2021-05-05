
%% get data
addpath('C:\Git\nastran_import_tool\f06')

% parameters
initial_fold_angle = 0;
flare_angle = 10;
origin = [0,1.00651180744171,0];

root_aoas = 2.5:2.5:10;
Vs = fliplr([15.75,17.5,21.25,25]);
data = [];
wb = waitbar(0,'Calculating coast angles');
error_count = 0;
for a_i = 1:length(root_aoas)
    f = @(x)get_fold_angle(x,flare_angle,origin,root_aoas(a_i),Vs(a_i));
    data = [data,find_zero_fold_angle(f,root_aoas(a_i))]; 
end
close(wb)

%% plot variation
figure(1)
% clf;
% colors = 'rbgckm';
% for a_i = 1:length(root_aoas)
%     idx = [data.root_aoa]==root_aoas(a_i);
%     % plot linear coast angle
%     tmp_idx = idx & [data.guess]==1;
%     p = plot([data(tmp_idx).V],[data(tmp_idx).fold_angle],[colors(a_i),'--']);
%     p.DisplayName = sprintf('%.0f degrees AoA',root_aoas(a_i));
%     hold on
%     % plot non-linear coast angle
%     tmp_idx = idx & arrayfun(@is_con,{data.state});
%     p = plot([data(tmp_idx).V],[data(tmp_idx).initial_fold],[colors(a_i),'-']);
%     if ~isempty(p)
%         p.Annotation.LegendInformation.IconDisplayStyle = 'off';
%     end
% end
% ylim([-200,90])
% legend('location','southeast')
% grid minor
% xlabel('Velocity [m/s]')
% ylabel('Coast Angle [deg]')
%% extra functions

function data = find_zero_fold_angle(f,root_aoa,varargin)
    p = inputParser();
    p.addParameter('IC',[-90,0,0]);
    p.addParameter('MaxIter',50);
    p.parse(varargin{:});
    data = [];
    camber_zero = fminbnd(@(x)f(x).^2,0,10,optimset('TolX',0.5));
    data(1).root_aoa = root_aoa;
    data(end).camber = camber_zero;    
end



function [res] = get_fold_angle(camber,flare_angle,origin,root_aoa,V)
    % get trim data
    data = get_trim_data(0,0,flare_angle,origin,root_aoa,...
        V,'DragMoment',0,'WingtipCamber',camber);
    
    %get fold angle
    res = get_fold_and_twist(data,0);
    res = res(1);
end

function res = get_fold_and_twist(data,fold_angle)
    twist_angle = rad2deg(data.thX(data.GP == 208));
    delta_fold = rad2deg(data.thX(data.GP == 209)) - twist_angle;
    fold_angle = fold_angle + delta_fold;
    res = [fold_angle,twist_angle];
end

