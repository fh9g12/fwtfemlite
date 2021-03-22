close all
model = mni.import_matran('C:\Git\fwtfemlite\sol144.bdf');
model.draw
res_disp =  mni.result.f06('sol144.f06').read_disp;
res_aeroP = mni.result.f06('sol144.f06').read_aeroP;
res_aeroF = mni.result.f06('sol144.f06').read_aeroF;

% apply deformation result
[~,i] = ismember(model.GRID.GID,res_disp.GP);
model.GRID.Deformation = [res_disp.dX(:,i);res_disp.dY(:,i);res_disp.dZ(:,i)];

%% apply aero result
model.CAERO1.PanelPressure = res_aeroP.Cp;

%f = [res_aeroF.aeroFx;res_aeroF.aeroFy;res_aeroF.aeroFz;...
%    res_aeroF.aeroMx;res_aeroF.aeroMy;res_aeroF.aeroMz];

%model.CAERO1.PanelForce = f';
model.update('Scale',1)