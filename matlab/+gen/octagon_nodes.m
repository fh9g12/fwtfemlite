function [points] = octagon_nodes(height,width,fillet,varargin)
%OCTAGON_NODES Summary of this function goes here
%   Detailed explanation goes here
p = inputParser();
p.addParameter('origin',[0,0]);
p.addParameter('FilletAngle',45);
p.parse(varargin{:})

x_fillet = fillet;
y_fillet = tand(p.Results.FilletAngle)*fillet;
points = zeros(8,2);
points(1,:) = [0,y_fillet];
points(2,:) = [0,height-y_fillet];
points(3,:) = [x_fillet,height];
points(4,:) = [width-x_fillet,height];
points(5,:) = [width,height-y_fillet];
points(6,:) = [width,y_fillet];
points(7,:) = [width-x_fillet,0];
points(8,:) = [x_fillet,0];
points = points + repmat(p.Results.origin(:)',8,1);
end

