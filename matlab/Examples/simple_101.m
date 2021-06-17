% parameters
fold_angle = 10;
twist_angle = 0;
flare_angle = 10;
origin = [0,1.00651180744171,0];
root_aoa = 4;



flut_data = get_101_data(fold_angle,twist_angle,flare_angle,...
    origin,root_aoa,false);
disp(rad2deg(flut_data.thX(flut_data.GP == 209)))
disp(rad2deg(flut_data.thX(flut_data.GP == 208)))