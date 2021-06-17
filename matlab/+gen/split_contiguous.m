function [out] = split_contiguous(A)
%SPLIT_CONTIGUOUS Summary of this function goes here
%   Detailed explanation goes here
out = {A(1),};
for i =2:length(A)
    if A(i)-out{end}(end) == 1
        out{end}(end+1) = A(i);
    else
        out{end+1} = A(i);
    end
end
end

