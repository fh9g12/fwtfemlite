classdef WT_model
    %FWT_COORDS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fold_angle = 0;
        flare_angle = 0;
        origin = [0 0 0];
        root_aoa = 0;
        twist_angle = 0;
        hinge_filename = 'hinge.bdf';
        fwt_coord_filename = 'fwt_coord.bdf';
        Locked = 0;
    end
    
    methods
        function obj = WT_model(fold_angle,twist_angle,flare_angle,origin,root_aoa)
            %FWT_COORDS Construct an instance of this class
            %   Detailed explanation goes here
            obj.fold_angle = fold_angle;
            obj.flare_angle = flare_angle;
            obj.origin = origin;
            obj.root_aoa = root_aoa;
            obj.twist_angle = twist_angle;
        end
        
        function writeToFile(obj,dir,varargin)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            p = inputParser();
            p.addParameter('GravStiffness',true,@is_logical_1_0);
            p.parse(varargin{:})
            %% write coords to file
            fid = fopen([dir,obj.fwt_coord_filename],'w+');
            awi.fe.FEBaseClass.writeFileStamp(fid);
            awi.fe.FEBaseClass.writeColumnDelimiter(fid,'8');
    
            elements = obj.gen_elements();            
            
            for i = 1:length(elements)
                elements{i}.writeToFile(fid,1)
            end
            fclose(fid);
            
            %% gen hinge data
            if p.Results.GravStiffness
                K = (0.365*0.2059 + 0.0876*0.3015)*9.81;
                K = (0.176*0.17 + 0.0876*0.3015)*9.81;
                K = -K*sind(obj.fold_angle+obj.twist_angle);
            else
                K = 0;
            end
            M =  -K*deg2rad(obj.twist_angle);
            % ensure stiffness is not completely zero
            if abs(K)<1e-4
                K=1e-4;
            end
            
            %% write to hinge file
            fid = fopen([dir,obj.hinge_filename],'w+');
            obj.write_hinge(fid,K,M);
            fclose(fid);
            
        end
        
        function write_hinge(obj,fid,hingeStiffness,Moment)
            awi.fe.FEBaseClass.writeFileStamp(fid);
            awi.fe.FEBaseClass.writeComment('this file contains the Hinge data for teh FWT WT Model',fid)
            awi.fe.FEBaseClass.writeColumnDelimiter(fid,'8');
            fl_cards = [{cards.Grid(208,[0,0,0],'CP',3,'CD',3)},...
                {cards.Grid(209,[0,0,0],'CP',3,'CD',3)}];
            if obj.Locked
                fl_cards = [fl_cards,{cards.RBE2(300,208,123456,209)}];
            else
                fl_cards = [fl_cards,...
                    {cards.RJoint(251,208,209,'CB','12356')},...
                    {cards.CBush(103,13,208,209,'CID',3)},...
                    {cards.PBush(13,'K',[0,0,0,hingeStiffness,0,0])},...
                    {cards.Moment(12,209,Moment,[1,0,0],'CID',3)}];
            end
            
            for i = 1:length(fl_cards)
                fl_cards{i}.writeToFile(fid)
            end
        end
        
        function elements = gen_elements(obj)
            % create transformation matricies
            wing_rot_m = roty(obj.root_aoa);
            hinge_rot_m = wing_rot_m*rotz(-obj.flare_angle);
            fwt_rot_m = hinge_rot_m*rotx(obj.fold_angle)*rotz(obj.flare_angle);
            aero_fwt_rot_m = rotx(obj.fold_angle);
            
            % create alena coord systems
            C_wing = awi.model.CoordSys('Origin',[0 0 0],'RMatrix',wing_rot_m);
            C_wingtip = awi.model.CoordSys('Origin',obj.origin,'RMatrix',fwt_rot_m);
            C_hinge = awi.model.CoordSys('Origin',obj.origin,'RMatrix',hinge_rot_m);
            C_aero = awi.model.CoordSys('Origin',obj.origin,'RMatrix',aero_fwt_rot_m);
            
            % convert to fem coord systems
            fem_C_wing = obj.awi_coord_2_fe(C_wing,1);
            fem_C_wingtip = obj.awi_coord_2_fe(C_wingtip,2);
            fem_C_hinge = obj.awi_coord_2_fe(C_hinge,3);
            fem_C_aero = obj.awi_coord_2_fe(C_aero,4);
            
            
            % generate twist on wingtip
            DMI = awi.fe.DMI();
            DMI.NAME = 'W2GJ';
            local_aoa = -atan(sind(obj.flare_angle)*sind(obj.fold_angle));
            rad_root_aoa = deg2rad(obj.root_aoa);
            DMI.DATA = [ones(400,1)*rad_root_aoa;...
                ones(150,1)*local_aoa+rad_root_aoa*cosd(obj.fold_angle)];
            
            % return elements
            elements = [{fem_C_wing},{fem_C_wingtip},...
                {fem_C_hinge},{fem_C_aero},{DMI}];
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

function res = is_logical_1_0(x)
    if islogical(x)
        res = true;
    elseif isnumeric(x) && (x==1 || x==0)
        res = true;
    else
        res = false;
    end
end

function [mat] = rotx(angle)
%ROTX Summary of this function goes here
%   Detailed explanation goes here
mat = eye(3);
mat(2:3,2:3) = [cosd(angle),-sind(angle);sind(angle),cosd(angle)];
end

function [mat] = roty(angle)
%ROTX Summary of this function goes here
%   Detailed explanation goes here
mat = eye(3);
mat([1,3],[1,3]) = [cosd(angle),sind(angle);-sind(angle),cosd(angle)];
end


function [mat] = rotz(angle)
%ROTX Summary of this function goes here
%   Detailed explanation goes here
mat = eye(3);
mat(1:2,1:2) = [cosd(angle),-sind(angle);sind(angle),cosd(angle)];
end