function save()
cp = campos;
ct = camtarget;
cu = camup;
cv = camva;
f = gcf;
fp = f.Position;
save('cam_pos.mat','cp','ct','cu','cv','fp')
end