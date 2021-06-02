function load()
load('cam_pos.mat','cp','ct','cu','cv','fp')
campos(cp);
camtarget(ct);
camup(cu);
camva(cv);
f = gcf;
f.Position = fp;
end