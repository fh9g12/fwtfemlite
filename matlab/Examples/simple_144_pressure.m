% parameters
fold_angle = -64.5;
flare_angle = 10;
origin = [0,1.00651180744171,0];
root_aoa = 5;
V=12.5;

[data,p_data] = get_trim_data(fold_angle,flare_angle,origin,root_aoa,V);
