function [mat] = rotz(angle)
%ROTX Summary of this function goes here
%   Detailed explanation goes here
mat = eye(3);
mat(1:2,1:2) = [cosd(angle),-sind(angle);sind(angle),cosd(angle)];
end

