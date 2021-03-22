function [mat] = rotx(angle)
%ROTX Summary of this function goes here
%   Detailed explanation goes here
mat = eye(3);
mat(2:3,2:3) = [cosd(angle),-sind(angle);sind(angle),cosd(angle)];
end

