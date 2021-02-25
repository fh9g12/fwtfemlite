function [x_res,guesses] = find_bounded_zero_golden(f,bounds,varargin)
%GOLDEN_SECTION Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    p.addRequired('function');
    p.addRequired('bounds',@(x)length(x)==2);
    p.addParameter('Xtol',1e-2);
    p.addParameter('Ytol',1e-2);
    p.addParameter('MaxIter',100);
    p.parse(f,bounds,varargin{:})
    x = sort(bounds);
    y = arrayfun(f,x);
    if abs(y(1))<abs(y(2))
        x_new = x(1)+(x(2)-x(1))*0.382;
    else
        x_new = x(1)+(x(2)-x(1))*0.618;
    end
    x = [x(1),x_new,x(2)];
    y = [y(1),f(x_new),y(2)];
    [~,i] = sort(y);
    if i(3)== 2
        error('minimimium does not lie in the initial bracket')
    end
    guesses = ones(p.Results.MaxIter,2)*NaN;
    guesses = [x',y';guesses];

    for i = 1:p.Results.MaxIter
        % check if in tolerance
        if range(x)<p.Results.Xtol
            break;
        end
        if (x(2)-x(1))>(x(3)-x(2))
            x_new = x(2)-(x(2)-x(1))*0.382;
            y_new = f(x_new);
            if y_new<y(2)
                x = [x(1),x_new,x(2)];
                y = [y(1),y_new,y(2)];
            else
                x = [x_new,x(2),x(3)];
                y = [y_new,y(2),y(3)];
            end
        else
            x_new = x(2)+(x(3)-x(2))*0.382;
            y_new = f(x_new);
            if y_new<y(2)
                x = [x(2),x_new,x(3)];
                y = [y(2),y_new,y(3)];
            else
                x = [x(1),x(2),x_new];
                y = [y(1),y(2),y_new];
            end
        end
        % check its within the bounds
        [~,y_i] = sort(y);
        if y_i(3)== 2
            error('minimimium does not lie in the bracket')
        end
        % add to guesses
        guesses(3+i,:) = [x_new,y_new];  
        if y_new<p.Results.Ytol
            break
        end
    end
    guesses(isnan(guesses(:,1)),:) = [];
    [~,i] = min(guesses(:,2).^2);
    x_res = guesses(i,1);
end

function r = range(x)
    r = max(x) - min(x);
end

