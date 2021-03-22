close all
model = mni.import_matran('C:\Git\fwtfemlite\sol103.bdf');
model.draw

% get modal data
res_modeshape = mni.result.f06('sol103.f06').read_modeshapes;
res_freq = mni.result.f06('sol103.f06').read_modes;
%% apply deformation result
modeshape_num = 4;

[~,i] = ismember(model.GRID.GID,res_modeshape.GID(modeshape_num,:));
model.GRID.Deformation = [res_modeshape.T1(modeshape_num,i);...
    res_modeshape.T2(modeshape_num,i);res_modeshape.T3(modeshape_num,i)];

model.update()
model.animate('Frequency',2,'Scale',0.2) 