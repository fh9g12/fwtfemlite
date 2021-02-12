addpath('C:\Git\nastran_import_tool\f06')
trim_file = 'C:\Git\fwtfemlite\trim.bdf';
flut_file = 'C:\Git\fwtfemlite\flutter.bdf';

%write_trim(trim_file,1.225,Vs(v_i),deg2rad(root_aoas(a_i)));
% origin = [0,1.00651180744171,0];
% f = gen_fwt_coords(-45,10,origin);
% f.Name = 'fwt_coord';
% export(f, run_folder);

% Vs = [12.5,15,17.5,20,22.5,25,27.5,30,32.5,35,37.5,40];
% Vs = linspace(14,50,19);
% root_aoas = [0,5,10]; 

fold_angle = 20;
flare_angle = 10;
origin = [0,1.00651180744171,0];
% run_folder = 'C:\Git\fwtfemlite\';

fid = fopen('C:\Git\fwtfemlite\fwt_coord.bdf','w+');
coords = fwt_coords(fold_angle,flare_angle,origin);
coords.writeToFile(fid)

write_trim(trim_file,1.225,21,5)
write_flutter(flut_file,1,0,21)

% write_fwt_coords('C:\Git\fwtfemlite\',fold_angle,flare_angle,origin)
% 
% For each velocity first find the equlibrium angle and the calc dynamic
% response
% for a_i = 1:length(root_aoas)
% for v_i = 1:length(Vs)
%     find the coast angle
%     fold_estimates = [fold_angle];
%     write_trim(trim_file,1.225,Vs(v_i),deg2rad(root_aoas(a_i)));
%     for i =1:4
%         delete('sol144.*')
%         theta = fold_estimates(end);
%         f = gen_fwt_coords(theta,flare_angle,origin);
% 
%         DMI = awi.fe.DMI();
%         DMI.NAME = 'W2GJ';
%         local_aoa = -atan(sind(flare_angle)*sind(theta));
%         disp(rad2deg(local_aoa))
%         DMI.DATA = [zeros(400,1);ones(150,1)*local_aoa];
%         f.addFEData(DMI);
%         f.Name = 'fwt_coord';
%         export(f, run_folder);
%         command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol144.bdf'];
%         system(command);
%         d = read_f06_disp('','sol144');
%         fold_estimates(end+1) = rad2deg(d.thX(d.GP==209))*0.613+fold_estimates(end);
%         
%         if fold_estimates(end)>90
%             fold_estimates(end) = 90;
%         elseif fold_estimates(end) < -90
%             fold_estimates(end) = -90;
%         end
%         disp(fold_estimates(end))
%     end
%     delete('sol145.*')
%     write_flutter(flut_file,Vs(v_i));
%     command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol145.bdf'];
%     system(command);
%     flut_data = read_f06_flutter('','sol145');
%     for i = 1:length(flut_data)
%         flut_data(i).FOLD = fold_estimates(end);
%         flut_data(i).AoA = root_aoas(a_i);     
%     end
%     if (a_i == 1) && (v_i == 1)
%         final_data = flut_data;
%     else
%         final_data = horzcat(final_data,flut_data);
%     end
% end
% end
% figure(1);
% clf;
% plot_flutter(final_data([final_data.AoA]== 0),0,1,2,'-');
% plot_flutter(final_data([final_data.AoA]== 5),0,1,2,'--');
% plot_flutter(final_data([final_data.AoA]== 10),0,1,2,'-.');

% 
% 

% delete('sol145.*')
% command = ['C:\MSC.Software\MSC_Nastran\20181\bin\nastran.exe',' ','C:\Git\fwtfemlite\sol145.bdf'];
% system(command);
% d = read_f06_flutter('','sol145');
% figure(2);
% plot_flutter(d,0,1,4);




