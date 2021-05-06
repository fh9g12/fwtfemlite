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
        aero_filename = 'aero.bdf';
        Locked = 0;
        wing_camber = 0;
        wingtip_camber = 0;
        tunnel_walls = false;
        wingtip_cl_correction = 1;
        include_sweep = false;
    end
    
    methods
        function obj = WT_model(fold_angle,twist_angle,flare_angle,origin,root_aoa,varargin)
            %FWT_COORDS Construct an instance of this class
            %   Detailed explanation goes here
            p=inputParser();
            p.addParameter('include_sweep',false);
            p.parse(varargin{:});
            obj.fold_angle = fold_angle;
            obj.flare_angle = flare_angle;
            obj.origin = origin;
            obj.root_aoa = root_aoa;
            obj.twist_angle = twist_angle;
            obj.include_sweep = p.Results.include_sweep;
        end
        function write_aero(obj,fid,varargin)
            awi.fe.FEBaseClass.writeFileStamp(fid);
            awi.fe.FEBaseClass.writeComment('this file contains the Aero data for the FWT Model',fid)
            awi.fe.FEBaseClass.writeColumnDelimiter(fid,'8');
            %create main wing aero panels
            main_id = 100001;
            fwt_id  = 101001;
            
            rad_root_aoa = deg2rad(obj.root_aoa);
            
            v_fwt = gem(obj.fold_angle,1,obj.root_aoa,0,obj.flare_angle,0);
            fwt_local_aoa = atan(v_fwt(3)./v_fwt(1));           
            %fwt_local_aoa = -atan(sind(obj.flare_angle)*sind(obj.fold_angle))+rad_root_aoa*cosd(obj.fold_angle);
            if obj.include_sweep
                fwt_local_sweep = atan(v_fwt(2)./v_fwt(1));
            else
                fwt_local_sweep = 0;
            end
            fwt_span = 0.333849;
            
            
            awi.fe.FEBaseClass.writeComment('Main Wing Aero Panels',fid)
            cards.PAERO1(main_id).writeToFile(fid);
            cards.CAERO1(main_id,main_id,[-0.0375,0.0335,0],...
            [-0.0375,obj.origin(2),0],0.15,0.15,1,...
            'CP',0,'NSPAN',40,'NCHORD',10).writeToFile(fid);
        
            awi.fe.FEBaseClass.writeComment('FWT Aero Panels',fid)
            cards.PAERO1(fwt_id).writeToFile(fid)
            cards.CAERO1(fwt_id,fwt_id,[-0.0375,0,0],...
            [-0.0375+tan(fwt_local_sweep)*fwt_span,fwt_span,0],0.15,0.15,1,...
            'CP',4,'NSPAN',15,'NCHORD',10).writeToFile(fid)

            awi.fe.FEBaseClass.writeComment('Main Spline',fid)
            cards.SPLINE4(7,'CAERO',main_id,'AELIST',2,'SETG',2,...
                    'METH','IPS','USAGE','BOTH').writeToFile(fid);
            cards.AELIST(2,main_id:main_id+399).writeToFile(fid);
            cards.SET1(2,[2,4:11,13:22,24:33,35:44,...
                            46:55,57,66,68:77,79:88,90:99,208,...
                            114:147,200:205]).writeToFile(fid);
        
            awi.fe.FEBaseClass.writeComment('FWT Spline',fid)
            cards.SPLINE4(8,'CAERO',fwt_id,'AELIST',1,'SETG',1,...
                    'METH','IPS','USAGE','BOTH').writeToFile(fid);
            cards.AELIST(1,fwt_id:fwt_id+149).writeToFile(fid);
            cards.SET1(1,[209,221,148:151,210:215]).writeToFile(fid);

            % write some AESTAT cards
            names = {'ANGLEA','SIDES','ROLL','PITCH','YAW',...
                'URDD1','URDD2','URDD3','URDD4','URDD5','URDD6'};
            for i = 1:length(names)
                cards.AESTAT(i,names{i}).writeToFile(fid);
            end
            
            
            
            
%             function [cl_alpha,cl_0] = get_clalpha(aoa)
%                 cl_alpha = ones(size(aoa))*0.537;
%                 cl_0 = zeros(size(aoa));
%                 
%                 ind = abs(aoa)<=deg2rad(4.5);
%                 cl_alpha(ind) = 1.2426;
%                 cl_0(~ind) = deg2rad(7.0535);
%             end
            function [cl_alpha,cl_0] = get_clalpha(aoa)
                cl_alpha = ones(size(aoa))*obj.wingtip_cl_correction;
                cl_0 = zeros(size(aoa));
            end
            
            aoa = [ones(400,1)*rad_root_aoa+deg2rad(obj.wing_camber);...
                ones(150,1)*fwt_local_aoa+deg2rad(obj.wingtip_camber)];
            [cl_alpha,cl_0] = get_clalpha(aoa);
            aoa = aoa + cl_0;
            
            % generate twist on wingtip
            DMI_W2GJ = awi.fe.DMI();
            DMI_W2GJ.NAME = 'W2GJ';      
            DMI_W2GJ.DATA = aoa;
            if obj.tunnel_walls
                DMI_W2GJ.DATA = [DMI_W2GJ.DATA;zeros(8*16*8,1)];
            end
            DMI_W2GJ.writeToFile(fid,1);
            
            % generate wingtip C_l correction factor
            DMI_WKK = awi.fe.DMI();
            DMI_WKK.NAME = 'WKK';
            DMI_WKK.FORM = 3;
            DMI_WKK.DATA = reshape(repmat(cl_alpha',2,1),[],1);
            %DMI_WKK.DATA = [ones(800,1);ones(300,1)*obj.wingtip_cl_correction];
            if obj.tunnel_walls
                DMI_WKK.DATA = [DMI_WKK.DATA;ones(8*16*8*2,1)];
            end
            DMI_WKK.writeToFile(fid,1);
            
            if obj.tunnel_walls
               awi.fe.FEBaseClass.writeComment('Tunnel Walls',fid)
               nodes = gen.octagon_nodes(1.524,2.1336,0.6146,...
                   'FilletAngle',32,'origin',[0,-1.524/2]);
               nodes = [repmat(-2,8,1),nodes];
               nodes(end+1,:) = nodes(1,:);
               pid = 102001;
               for i = 1:size(nodes,1)-1
                   cards.PAERO1(pid).writeToFile(fid)
                   cards.CAERO1(pid,pid,nodes(i,:),...
                   nodes(i+1,:),4,4,1,...
                   'NSPAN',8,'NCHORD',16).writeToFile(fid)
                   pid = pid + (8*16);
               end
            end
        end
        
        function writeToFile(obj,dir,varargin)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            p = inputParser();
            p.addParameter('GravStiffness',true,@is_logical_1_0);
            p.addParameter('DragMoment',0);
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
                K = (0.424*0.153 + 0.094*0.3015)*9.81;
                K = -K*sind(obj.fold_angle+obj.twist_angle);
            else
                K = 0;
            end
            M =  -K*deg2rad(obj.twist_angle);
            M = M + p.Results.DragMoment;
            % ensure stiffness is not completely zero
            if abs(K)<1e-4
                K=1e-4;
            end
            
            %% write to hinge file
            fid = fopen([dir,obj.hinge_filename],'w+');
            obj.write_hinge(fid,K,M);
            fclose(fid);
            
            %% write to aero file
            fid = fopen([dir,obj.aero_filename],'w+');
            obj.write_aero(fid);
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
            
            % return elements
            elements = [{fem_C_wing},{fem_C_wingtip},...
                {fem_C_hinge},{fem_C_aero}];
        end
        function vec = fwt_normal_vector(obj)
            % create transformation matricies
            wing_rot_m = roty(obj.root_aoa);
            hinge_rot_m = wing_rot_m*rotz(-obj.flare_angle);
            fwt_rot_m = hinge_rot_m*rotx(obj.fold_angle)*rotz(obj.flare_angle);
            vec = fwt_rot_m*[0,0,1]';
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