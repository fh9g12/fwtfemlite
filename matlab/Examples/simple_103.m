% parameters
fold_angle = 10;
flare_angle = 10;
twist_angle = 0;
origin = [0,1.00651180744171,0];
root_aoa = 4;
locked = true;

f_data = get_103_data(fold_angle,twist_angle,flare_angle,...
    origin,root_aoa,locked);