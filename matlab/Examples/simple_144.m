%% parameters
fold_angle = 20;
twist_angle = 0;
flare_angle = 10;
origin = [0,1.00651180744171,0];
root_aoa = 10;
V=18;
%% get Data
[data,p_data,f_data] = get_trim_data(fold_angle,twist_angle,flare_angle,...
    origin,root_aoa,V,'Locked', true,'TunnelWalls',false);
twist = rad2deg(data.thX(data.GP == 208));
fold = fold_angle + rad2deg(data.thX(data.GP == 209)) - twist;
fprintf('Twist Angle: %.2f deg\n',twist);
fprintf('Fold Angle: %.2f deg\n',fold);

Ajj = op4ToMatrix('ajj.op4');% get_dmi_entry('AJJ','C:\Git\fwtfemlite\matlab\sol144.pch');
FFAj = op4ToMatrix('ffaj.op4');
res_aeroP = mni.result.f06('sol144.f06').read_aeroP;
res_aeroF = mni.result.f06('sol144.f06').read_aeroF;

q = (0.5*1.225*V^2);
WJ = Ajj*(FFAj./q);

panels = [10,15];
xx = linspace(0,0.333849,panels(2)*2+1);
xx = xx(2:2:panels(2)*2)*cosd(10);
mom_arm = reshape(repmat(xx,panels(1),1),length(xx)*panels(1),[]);
model = gen.WT_model(fold_angle,twist_angle,flare_angle,origin,root_aoa);
surface_normal = model.fwt_normal_vector();

idx = 401:550;

fwt_drag = sin(WJ(idx)).*res_aeroF.aeroFz(idx)';
drag_mag = dot([1 0 0],surface_normal);
drag_mom = sum(fwt_drag.*drag_mag.*mom_arm);

model = mni.import_matran('C:\Git\fwtfemlite\sol144.bdf');
model.draw()
f = [res_aeroF.aeroFx;res_aeroF.aeroFy;res_aeroF.aeroFz;...
    res_aeroF.aeroMx;res_aeroF.aeroMy;res_aeroF.aeroMz];

model.CAERO1.PanelForce = f';
model.update('Scale',2)

%% plot pressure

%load model

% model = mni.import_matran('C:\Git\fwtfemlite\sol144.bdf');
% model.draw()
% 
% % apply deformation result
% [~,i] = ismember(model.GRID.GID,data.GP);
% model.GRID.Deformation = [data.dX(:,i);data.dY(:,i);data.dZ(:,i)];
% 
% %% apply aero result
% model.CAERO1.PanelPressure = p_data.Cp;
% 
% f = [f_data.aeroFx;f_data.aeroFy;f_data.aeroFz;...
%     f_data.aeroMx;f_data.aeroMy;f_data.aeroMz];
% 
% model.CAERO1.PanelForce = f';
% model.update('Scale',1)
% 
% %% plot Cp distribution
% le_cp = p_data.Cp(1:10:length(p_data.Cp));
% figure(4);clf;plot(([1:55,55.5])/55.5,[le_cp,0])
% xlabel('Normalised span Location')
% ylabel('Cp')