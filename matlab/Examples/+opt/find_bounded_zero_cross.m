function [x_res,guesses] = find_bounded_zero_cross(f,bounds,varargin)
%GOLDEN_SECTION Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    p.addRequired('function');
    p.addRequired('bounds',@(x)length(x)==2);
    p.addParameter('Xtol',1e-2);
    p.addParameter('Ytol',1e-2);
    p.addParameter('MaxIter',100);
    p.addParameter('Lookup',[],@(x) size(x,2)==2);
    p.parse(f,bounds,varargin{:})
    x = sort(bounds);
    guesses = [ones(p.Results.MaxIter+2,2)*NaN;p.Results.Lookup];
    
    function y = f_lookup(x_in)
        f_i = find(guesses(:,1)==x_in);
        if ~isempty(f_i)
            y = guesses(f_i(1),2);
            return
        end
        y = f(x_in);
    end
    y = arrayfun(@f_lookup,x);
    guesses(1:2,:) = [x',y'];
    [~,y_i] = sort(y);

    for i = 1:p.Results.MaxIter
        % check if in tolerance
        if range(x)<p.Results.Xtol
            break;
        end
        % get the predicted zero crossing position
        tmp_m = (y(2)-y(1))/(x(2)-x(1));
        tmp_x = x(1)- y(1)/tmp_m;
        
        % check not 'stuck' close to one end
        if min(abs(x-tmp_x)/range(x))<0.05
            tmp_x = mean(x);
        end

        
        % check its within the bounds
        if tmp_x<x(1) || tmp_x>x(2)
            error('No zero crossing within bounds')
        end
        tmp_y = f_lookup(tmp_x);

        % add to guesses
        guesses(2+i,:) = [tmp_x,tmp_y];
        if abs(tmp_y) < p.Results.Ytol
            break
        end
        if tmp_y>0
            y(y_i(2)) = tmp_y;
            x(y_i(2)) = tmp_x;
        elseif tmp_y<0
            y(y_i(1)) = tmp_y;
            x(y_i(1)) = tmp_x;
        else
            break;
        end
    end
    if ~isempty(p.Results.Lookup)
        guesses(end-size(p.Results.Lookup,1):end,:) = [];
    end
    guesses(isnan(guesses(:,1)),:) = [];
    [~,i] = min(guesses(:,2).^2);
    x_res = guesses(i,1);
end

function r = range(x)
    r = max(x) - min(x);
end

