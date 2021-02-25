
%% get data
addpath('C:\Git\nastran_import_tool\f06')

% parameters
initial_fold_angle = -90;
flare_angle = 10;
origin = [0,1.00651180744171,0];

root_aoas = 0:2.5:10;
Vs = 2:2:40;
data = [];
wb = waitbar(0,'Calculating coast angles');
error_count = 0;
for a_i = 1:length(root_aoas)
    fold_angle = initial_fold_angle;
    for v_i = 1:length(Vs)      
%         try
            waitbar(((a_i-1)*length(Vs)+v_i)/(length(root_aoas)*length(Vs)),wb,'Calculating coast angles');
            tmp_data = find_coast_angle(flare_angle,origin,root_aoas(a_i),Vs(v_i),'Bracket',[0,20]+fold_angle);
            data = [data,tmp_data];
            fold_angle = data(end).initial_fold;
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

function data = find_coast_angle(flare_angle,origin,root_aoa,V,varargin)
    p = inputParser();
    p.addParameter('Bracket',[-90,0]);
    p.addParameter('MaxIter',50);
    p.parse(varargin{:});
    data = [];
    
    f = @(x)get_fold_angle(x,flare_angle,origin,root_aoa,V)-x;  
    
    % add zero fold point to data   
    data = append_guess_data(data,[0,f(0)],root_aoa,V);
    
    current_guesses = @(x)[[x.initial_fold]',[x.fold_angle]'-[x.initial_fold]'];
       
    % check if initial answer gives a result close enough (e.g. in the 
    % 'linear' range) to use the simple algothrim of using the last answer 
    % as the next guess
    if data(1).fold_angle > -30
        [~,cross_data] = fmincon_coast(f,data(1).fold_angle,'MaxIter',...
            p.Results.MaxIter,'Xtol',0.1,'Ytol',0.1,...
            'Lookup',current_guesses(data));
    else
        bracket = p.Results.Bracket;
        % test if the fold angle is diverging around the left handside of
        % the bracket, if it is find a suitable bracket
        res = [p.Results.Bracket(1);p.Results.Bracket(1)+0.5;p.Results.Bracket(2)];
        data = append_guess_data(data,[res,arrayfun(f,res)],root_aoa,V);
        
        if (abs(data(end-2).fold_angle - data(end-2).initial_fold)<...
                abs(data(end-1).fold_angle - data(end-1).initial_fold))                
            % either start of bracket diverging or no zero crossing so
            % march from the start of the bracket
            [bracket,cross_data] = opt.marching_zero_cross(f,p.Results.Bracket(1),...
                'StepSize',0.5,'MaxIter',60,'Lookup',current_guesses(data),...
                'Direction','falling');
            data = append_guess_data(data,cross_data,root_aoa,V); 
        elseif (data(end).fold_angle * data(end-2).fold_angle > 0)
            if data(end-2).fold_angle-data(end-2).initial_fold<0
                direction = 'rising';
            else
                direction = 'falling';
            end
            [bracket,cross_data] = opt.marching_zero_cross(f,p.Results.Bracket(1),...
                'StepSize',0.5,'MaxIter',60,'Lookup',current_guesses(data),...
                'Direction',direction);
            data = append_guess_data(data,cross_data,root_aoa,V); 
        end
        % search bracket for zero crossing
        [~,cross_data] = opt.find_bounded_zero_cross(f,bracket,...
            'Xtol',0.1,'Ytol',0.1,'MaxIter',p.Results.MaxIter,...
            'Lookup',current_guesses(data));
    end
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
    p.addParameter('Lookup',[],@(x) size(x,2)==2)
    p.parse(f,ic,varargin{:})
       
    guesses = [ones(p.Results.MaxIter,2)*NaN;p.Results.Lookup];
    
    function y = f_lookup(x)
        f_i = find(guesses(:,1)==x);
        if ~isempty(f_i)
            y = guesses(f_i(1),2);
            return
        end
        y = f(x);
    end
    
    guesses(1,:) = [ic,f_lookup(ic)];
    for i = 2:p.Results.MaxIter
        gain = 1;
        if abs(guesses(i-1,2)-guesses(i-1,1))>20
            gain=0.5;
        end
        tmp_x = guesses(i-1,1) + gain * p.Results.Gain * guesses(i-1,2);
        tmp_y = f_lookup(tmp_x);
        guesses(i,:) = [tmp_x,tmp_y];
        if abs(tmp_y) < p.Results.Ytol
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
    [~,i] = min(tmp_y);
    res = tmp_x(i);   
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
        data(end).fold_angle = cross_data(i,2)+cross_data(i,1);
    end
end



function fold = get_fold_angle(fold_angle,flare_angle,origin,root_aoa,V)
    
    % get trim data
    data = get_trim_data(fold_angle,flare_angle,origin,root_aoa,V);
    
    %get fold angle
    fold = rad2deg(data.thX(data.GP == 209));
    fold = fold - rad2deg(data.thX(data.GP == 208));
    
    fold = fold_angle + fold;
end
