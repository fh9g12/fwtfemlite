function [res,guesses] = marching_zero_cross(func,IC,varargin)
% marching_zero_cross - finds a bracket in which zero is crossed in the 
% function 'func' on either a rising or falling edge
%
% this is achieved by marching from the initial conditon IC in step sizes
% of 'StepSize' a maximum of 'MaxIter' times untill a zero cross is found
% in the direction specified by 'Direction'. The full list of parameters is
%   - func: a function handle to the func to be minimised. it should take
%   one argument
%   - IC: the inital condition passed to func
%   - StepSize - the size of step taken from IC on each iteration
%   - MaxIter: the maximum number of steps taken
%   - Lookup: a nx2 array of positions already calculated using func where
%       the first column is the input and the second is the output
%   - Direction: the direction of edge to look for. Either 'rising' or
%       'falling'
%
    expected_directions = {'rising','falling'};
    p = inputParser();
    p.addRequired('function');
    p.addRequired('IC');
    p.addParameter('StepSize',1);
    p.addParameter('MaxIter',20);
    p.addParameter('Lookup',[],@(x) size(x,2)==2)
    p.addParameter('Direction','falling',...
        @(x) any(validatestring(x,expected_directions)))
    p.parse(func,IC,varargin{:});
    
    guesses = [ones(p.Results.MaxIter,2)*NaN;p.Results.Lookup];
    
    function y = f_lookup(x)
        f_i = find(guesses(:,1)==x);
        if ~isempty(f_i)
            y = guesses(f_i(1),2);
            return
        end
        y = func(x);
    end
    
    guesses(1,:) = [p.Results.IC,f_lookup(p.Results.IC)];
    for i = 2:p.Results.MaxIter
        tmp_x = p.Results.IC + (i-1) * p.Results.StepSize;
        tmp_y = f_lookup(tmp_x);
        guesses(i,:) = [tmp_x,tmp_y];
        if guesses(i-1,2)*guesses(i,2)<0
            % crossing dectected
            if (guesses(i,2)>guesses(i-1,2) && strcmp('rising',p.Results.Direction))...
                    ||...
                    (guesses(i,2)<guesses(i-1,2) && strcmp('falling',p.Results.Direction))
                res = guesses(i-1:i,1)';
                break;
            end
        elseif i == p.Results.MaxIter
            error('Zero crossing not found')
        end
    end
    if ~isempty(p.Results.Lookup)
        guesses(end-size(p.Results.Lookup,1):end,:) = [];
    end
    guesses(isnan(guesses(:,1)),:) = [];
end

