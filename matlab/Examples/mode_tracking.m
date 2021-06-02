function data = mode_tracking(data,modes,varargin)
%MODE_TRACKING corrects the modes numbers in flutter data
%
%   In the flutter data 'data' the function sweeps through each velocity
%   and tracks which modes line up with the previous modes by first
%   checking how much the frequencies have changed and if they are close
%   how the dampings have changed. Inputs are:
%       data - flutter data
%       modes - number of modes to check
%   outputs:
%       data - the original data structre with the mode numbers corrected
% deal with input parameters
p = inputParser();
p.addParameter('manual_switch',{});
p.parse(varargin{:})

v_switch = cellfun(@(x)x{1},p.Results.manual_switch);

% find all unique velocities
Vs = sort(unique([data.V]));

% setup structure to record how mode numbers change (row n will show how
% the original mode n changes across all velocties)
mode_track = zeros(modes,length(Vs));
mode_track(:,1) = 1:modes;
for v_i = 2:length(Vs)
   % check if we are manual switch modes 
   idx = find(v_switch==Vs(v_i),1);
   if ~isempty(idx)
       M_f = p.Results.manual_switch{idx}{2};
       mode_track(:,v_i) = mode_track(M_f,v_i-1);
       continue
   end
    
   % get frequency and damping data for this and previous velocity
   [last_f,last_d] = extract_freq_damping(data([data.V]==Vs(v_i-1)),mode_track(:,v_i-1));
   [next_f,next_d] = extract_freq_damping(data([data.V]==Vs(v_i)),mode_track(:,v_i-1));
   
   % produce wieghting matrix for how far each point is from the others
   M_f = weighting_matrix(last_f,next_f,0.8);
   
   % see how many modes can not be easily identifeied for weighting matrix
   unsure_modes = [];
   for i = 1:modes
       if M_f(i,i) ~= 1
           unsure_modes = [unsure_modes,find(M_f(i,:)>0 & M_f(i,:)<1)];
       end
   end
   unsure_modes = unique(unsure_modes);
   % if none are unsure modes are same as last velocity
   if isempty(unsure_modes)
       mode_track(:,v_i) = mode_track(:,v_i-1);
       continue
   end
   
   % produce damping weighting matrix for unsure modes
   M_d = weighting_matrix(last_d(unsure_modes),next_d(unsure_modes),0.7);
   % if there is no certainty in this matrix modes are too close to
   % each other so just skip to next time step
   if sum(M_d(:,1))~=1
       mode_track(:,v_i) = mode_track(:,v_i-1);
       continue
   end
   % replace parts of M_f with new matrix
   M_f(unsure_modes,unsure_modes) = M_d;
   for i=1:modes
       mode_track(i,v_i) = mode_track(find(M_f(i,:),1),v_i-1);
   end
end

% work through data structure and replace mode numbers accordingly
for v_i = 2:length(Vs)
    tmp_idx = [data.V]==Vs(v_i);
    mode_idx = zeros(1,modes);
    for i = 1:modes
        mode_idx(i) = find(tmp_idx & [data.MODE]==i,1);
    end
    for i = 1:modes
        data(mode_idx(i)).MODE = mode_track(i,v_i);
    end
end
end

function M = weighting_matrix(last,next,wieghting)
    M = zeros(length(last));
    for i = 1:length(last)
        for j = 1:length(next)
            M(i,j) = 1/abs(last(i)-next(j));
        end

    end
    s = sum(M,2);
    for i = 1:length(last)
        M(:,i) = M(:,i)./s;
    end
    M(M>wieghting) = 1;
    M(M<1-wieghting) = 0;
    
end

function [frequency,damping] = extract_freq_damping(data,modes)
    frequency = zeros(length(modes),1);
    damping = zeros(length(modes),1);
    for i = 1:length(modes)
        idx = find([data.MODE]==modes(i),1);
        frequency(i) = data(idx).F;
        damping(i) = data(idx).D;
    end
end

