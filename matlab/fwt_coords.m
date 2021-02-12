classdef fwt_coords
    %FWT_COORDS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fold_angle = 0;
        flare_angle = 0;
        origin = [0 0 0];
        root_aoa = 0;
    end
    
    methods
        function obj = fwt_coords(fold_angle,flare_angle,origin)
            %FWT_COORDS Construct an instance of this class
            %   Detailed explanation goes here
            obj.fold_angle = fold_angle;
            obj.flare_angle = flare_angle;
            obj.origin = origin;
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            awi.fe.FEBaseClass.writeFileStamp(fid);
            %awi.fe.FEBaseClass.writeComment(fid,'this file contain the trim card for a 144 solution')
            awi.fe.FEBaseClass.writeColumnDelimiter(fid,'8');
    
            elements = obj.gen_elements();
            
            
            for i = 1:length(elements)
                elements{i}.writeToFile(fid,1)
            end
        end
        
        function elements = gen_elements(obj)
            % create transformation matricies
            hinge_rot_m = roty(obj.root_aoa)*rotz(-obj.flare_angle);
            fwt_rot_m = hinge_rot_m*rotx(obj.fold_angle)*rotz(obj.flare_angle);
            aero_fwt_rot_m = rotx(obj.fold_angle);
            
            % create alena coord systems
            C_wingtip = awi.model.CoordSys('Origin',obj.origin,'RMatrix',fwt_rot_m);
            C_hinge = awi.model.CoordSys('Origin',obj.origin,'RMatrix',hinge_rot_m);
            C_aero = awi.model.CoordSys('Origin',obj.origin,'RMatrix',aero_fwt_rot_m);
            
            % convert to fem coord systems
            fem_C_wingtip = obj.awi_coord_2_fe(C_wingtip,1);
            fem_C_hinge = obj.awi_coord_2_fe(C_hinge,2);
            fem_C_aero = obj.awi_coord_2_fe(C_aero,3);
            
            % generate twist on wingtip
            DMI = awi.fe.DMI();
            DMI.NAME = 'W2GJ';
            local_aoa = -atan(sind(obj.flare_angle)*sind(obj.fold_angle));
            rad_root_aoa = deg2rad(obj.root_aoa);
            DMI.DATA = [ones(400,1)*rad_root_aoa;...
                ones(150,1)*local_aoa+rad_root_aoa*cosd(obj.fold_angle)];
            
            % return elements
            elements = [{fem_C_wingtip},{fem_C_hinge},{fem_C_aero},{DMI}];
        end
    end
    
    methods(Static)
        function fe_coord_sys = awi_coord_2_fe(awi_coord_sys,cid)
            A = awi_coord_sys.AbsPosition'; % origin
            B = awi_coord_sys.RMatrix*[0;0;1]+A; % point along z axis
            C = awi_coord_sys.RMatrix*[1;0;0]+A; % point along x axis

            fe_coord_sys = awi.fe.CoordSys();

            %Assign data
            fe_coord_sys.CID = cid;
            set(fe_coord_sys, {'A'}, num2cell(A, 1)');
            set(fe_coord_sys, {'B'}, num2cell(B, 1)');
            set(fe_coord_sys, {'C'}, num2cell(C, 1)');
        end
    end
end

