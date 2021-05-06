
%% get data
addpath('C:\Git\nastran_import_tool\f06')

% parameters
initial_fold_angle = -90;
flare_angle = 10;
origin = [0,1.00651180744171,0];

root_aoas = (2.5:2.5:10)+1.5;
% root_aoas = ([10])+1.5;
Vs = 0:2:40;
data = [];
wb = waitbar(0,'Calculating coast angles');
error_count = 0;
for a_i = 1:length(root_aoas)
    X = [initial_fold_angle,0,0];
    for v_i = 1:length(Vs)      
%         try
            waitbar(((a_i-1)*length(Vs)+v_i)/(length(root_aoas)*length(Vs)),wb,'Calculating coast angles');
            if Vs(v_i) == 0
                f = @(x)get_fold_angle_V0(x,flare_angle,origin,root_aoas(a_i))-x;
            else
                f = @(x)get_fold_angle(x,flare_angle,origin,root_aoas(a_i),Vs(v_i))-x;
            end
                
            data = [data,find_coast_angle(f,root_aoas(a_i),Vs(v_i),'IC',X)];
            X = [data(end).fold_angle,data(end).twist_angle,data(end).drag];
%         catch
%             fprintf('Skipping root aoa: %.1f deg, V: %.1f m/s\n',root_aoas(a_i),Vs(v_i));
%         end
    end   
end
close(wb)

%% plot variation
figure(1)
clf;
colors = 'rbgckm';
for a_i = 1:length(root_aoas)
    idx = [data.root_aoa]==root_aoas(a_i);
    % plot linear coast angle
    tmp_idx = idx & [data.guess]==1;
    p = plot([data(tmp_idx).V],[data(tmp_idx).fold_angle],[colors(a_i),'--']);
    p.DisplayName = sprintf('%.0f degrees AoA',root_aoas(a_i));
    hold on
    % plot non-linear coast angle
    tmp_idx = idx & arrayfun(@is_con,{data.state});
    p = plot([data(tmp_idx).V],[data(tmp_idx).initial_fold],[colors(a_i),'-']);
    if ~isempty(p)
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
end
ylim([-200,90])
legend('location','southeast')
grid minor
xlabel('Velocity [m/s]')
ylabel('Coast Angle [deg]')
%% extra functions

function idx = is_con(x)
    idx = 0;
    if ischar(x{1})
        if strcmp(x{1},'con')
            idx  = 1;
        end
    end
end

function data = find_coast_angle(f,root_aoa,V,varargin)
    p = inputParser();
    p.addParameter('IC',[-90,0,0]);
    p.addParameter('MaxIter',50);
    p.parse(varargin{:});
    data = [];
    
    % add zero fold point to data
    zero_IC = zeros(size(p.Results.IC));
    data = append_guess_data(data,[zero_IC,f(zero_IC)],root_aoa,V);
    
    current_guesses = @(x)[[x.initial_fold]',[x.initial_twist]',[x.initial_drag]'...
        [x.fold_angle]'-[x.initial_fold]',[x.twist_angle]'-[x.initial_twist]',...
        [x.drag]'-[x.initial_drag]'];
       
    IC = p.Results.IC;
    % test if the fold angle is diverging around the left handside of
    % the bracket, if it is find a suitable bracket
    data = append_guess_data(data,[IC,f(IC)],root_aoa,V);
    % search bracket for zero crossing
    [~,cross_data] = fmincon_coast(f,[data(end).fold_angle,data(end).twist_angle,data(end).drag],...
        'MaxIter',p.Results.MaxIter,'Xtol',0.1,'Ytol',0.1,...
        'Lookup',current_guesses(data));
    
    data = append_guess_data(data,cross_data,root_aoa,V,'i_offset',length(data));  
    data(end).state = 'con';
end


function [res,guesses] = fmincon_coast(f,ic,varargin)
    p = inputParser();
    p.addRequired('function');
    p.addRequired('IC');
    p.addParameter('Gain',1);
    p.addParameter('MaxIter',20);
    p.addParameter('Xtol',1e-2);
    p.addParameter('Ytol',1e-2);
    p.addParameter('Lookup',[],@(x) size(x,2)==6)
    p.parse(f,ic,varargin{:})
       
    guesses = [ones(p.Results.MaxIter,6)*NaN;p.Results.Lookup];
    
    function y = f_lookup(x)
        f_i = find(guesses(:,1)==x(1) & guesses(:,2)==x(2) & guesses(:,3)==x(3) );
        if ~isempty(f_i)
            y = guesses(f_i(1),4:6);
            return
        end
        y = f(x);
    end
    
    guesses(1,:) = [ic,f_lookup(ic)];
    for i = 2:p.Results.MaxIter
        gain = p.Results.Gain;
        if abs(guesses(i-1,4))>20
            gain=gain*0.5;
        elseif i>2 && abs((guesses(i-1,4)/guesses(i-2,4))+1)<0.1
            gain=gain*0.5;
        elseif i>10
            gain=gain*0.5;
        end
        tmp_x = guesses(i-1,1:3) + gain .* guesses(i-1,4:6);
        tmp_y = f_lookup(tmp_x);
        guesses(i,:) = [tmp_x,tmp_y];
        if abs(tmp_y(1)) < p.Results.Ytol
            break;
        elseif abs(guesses(i-1,1)-guesses(i,1)) < p.Results.Xtol
            break;
        elseif i == p.Results.MaxIter
            error ('Max iterations reached')
        end
    end
    if ~isempty(p.Results.Lookup)
        guesses(end-size(p.Results.Lookup,1):end,:) = [];
    end
    guesses(isnan(guesses(:,1)),:) = [];
    [~,i] = min(guesses(:,4));
    res = guesses(i,1:3);   
end

function data = append_guess_data(data,cross_data,root_aoa,V,varargin)
    p = inputParser();
    p.addParameter('i_offset',0);
    p.parse(varargin{:});
    len = length(data);
    for i = 1:size(cross_data,1)
        data(end+1).root_aoa = root_aoa;
        data(end).V = V;
        data(end).guess = len+i+p.Results.i_offset;
        data(end).initial_fold = cross_data(i,1);
        data(end).fold_angle = cross_data(i,4)+cross_data(i,1);
        data(end).initial_twist = cross_data(i,2);
        data(end).twist_angle = cross_data(i,5)+cross_data(i,2);
        data(end).initial_drag = cross_data(i,3);
        data(end).drag = cross_data(i,6)+cross_data(i,3);
    end
end



function [res] = get_fold_angle(X,flare_angle,origin,root_aoa,V)
    fold_angle = X(1);
    twist_angle = X(2);
    % get trim data
    data = get_trim_data(fold_angle,twist_angle,flare_angle,origin,root_aoa,...
        V,'DragMoment',X(3),'WingtipCamber',0,'TunnelWalls',true,...
        'fwt_cl_factor',1.12,'include_sweep',true);
    
    %get fold angle
    res = get_fold_and_twist(data,fold_angle);
    res(3) = get_drag_moment(fold_angle,twist_angle,flare_angle,origin,root_aoa,V);
end

function [res] = get_fold_angle_V0(X,flare_angle,origin,root_aoa)
    fold_angle = X(1);
    twist_angle = X(2);
    % get trim data
    data = get_101_data(fold_angle,twist_angle,flare_angle,origin,root_aoa,false);
    
    %get fold angle
    res = get_fold_and_twist(data,fold_angle);
    res(3) = 0;
end

function res = get_fold_and_twist(data,fold_angle)
    twist_angle = rad2deg(data.thX(data.GP == 208));
    delta_fold = rad2deg(data.thX(data.GP == 209)) - twist_angle;
    fold_angle = fold_angle + delta_fold;
    res = [fold_angle,twist_angle];
end

function res = get_drag_moment(fold_angle,twist_angle,flare_angle,origin,root_aoa,V)
    Ajj = op4ToMatrix('ajj.op4');
    FFAj = op4ToMatrix('ffaj.op4');
    res_aeroF = mni.result.f06('sol144.f06').read_aeroF;
    
    q = (0.5*1.225*V^2);
    WJ = Ajj*(FFAj./q);
    
    panels = [10,15];
    % get moment arm for each panel
    xx = linspace(0,0.333849,panels(2)*2+1);
    xx = xx(2:2:panels(2)*2)*cosd(flare_angle);
    mom_arm = reshape(repmat(xx,panels(1),1),length(xx)*panels(1),[]);
    
    % get FWT surface normal
    model = gen.WT_model(fold_angle,twist_angle,flare_angle,origin,root_aoa);
    surface_normal = model.fwt_normal_vector();

    %calc total drag moment
    idx = 401:550;
    fwt_drag = sin(WJ(idx)).*res_aeroF.aeroFz(idx)';
    drag_mag = dot([1 0 0],surface_normal);
    res = sum(fwt_drag.*drag_mag.*mom_arm);
end

