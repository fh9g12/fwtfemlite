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
            mni.printing.bdf.writeFileStamp(fid);
            mni.printing.bdf.writeComment('this file contains the Aero data for the FWT Model',fid)
            mni.printing.bdf.writeColumnDelimiter(fid,'8');
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
            
            
            mni.printing.bdf.writeComment('Main Wing Aero Panels',fid)
            mni.printing.cards.PAERO1(main_id).writeToFile(fid);
            mni.printing.cards.CAERO1(main_id,main_id,[-0.0375,0.0335,0],...
            [-0.0375,obj.origin(2),0],0.15,0.15,1,...
            'CP',0,'NSPAN',40,'NCHORD',10).writeToFile(fid);
        
            mni.printing.bdf.writeComment('FWT Aero Panels',fid)
            mni.printing.cards.PAERO1(fwt_id).writeToFile(fid)
            mni.printing.cards.CAERO1(fwt_id,fwt_id,[-0.0375,0,0],...
            [-0.0375+tan(fwt_local_sweep)*fwt_span,fwt_span,0],0.15,0.15,1,...
            'CP',4,'NSPAN',15,'NCHORD',10).writeToFile(fid)

            mni.printing.bdf.writeComment('Main Spline',fid)
            mni.printing.cards.SPLINE4(7,'CAERO',main_id,'AELIST',2,'SETG',2,...
                    'METH','IPS','USAGE','BOTH').writeToFile(fid);
            mni.printing.cards.AELIST(2,main_id:main_id+399).writeToFile(fid);
            mni.printing.cards.SET1(2,[2,4:11,13:22,24:33,35:44,...
                            46:55,57,66,68:77,79:88,90:99,208,...
                            114:147,200:205]).writeToFile(fid);
        
            mni.printing.bdf.writeComment('FWT Spline',fid)
            mni.printing.cards.SPLINE4(8,'CAERO',fwt_id,'AELIST',1,'SETG',1,...
                    'METH','IPS','USAGE','BOTH').writeToFile(fid);
            mni.printing.cards.AELIST(1,fwt_id:fwt_id+149).writeToFile(fid);
            mni.printing.cards.SET1(1,[209,221,148:151,210:215]).writeToFile(fid);
            
            function [cl_alpha,cl_0] = get_clalpha(aoa)
                cl_alpha = ones(size(aoa))*obj.wingtip_cl_correction;
                cl_0 = zeros(size(aoa));
            end
            
            aoa = [ones(400,1)*rad_root_aoa+deg2rad(obj.wing_camber);...
                ones(150,1)*fwt_local_aoa+deg2rad(obj.wingtip_camber)];
            [cl_alpha,cl_0] = get_clalpha(aoa);
            aoa = aoa + cl_0;
            
            % generate twist on wingtip
            DMI_W2GJ = mni.printing.cards.DMI('W2GJ',aoa,2,1,0);
            if obj.tunnel_walls
                DMI_W2GJ.MATRIX = [DMI_W2GJ.MATRIX;zeros(8*16*8,1)];
            end
            DMI_W2GJ.writeToFile(fid);
            
            % generate wingtip C_l correction factor
            DMI_WKK = mni.printing.cards.DMI('WKK',reshape(repmat(cl_alpha',2,1),[],1),3,1,0);
            if obj.tunnel_walls
                DMI_W2GJ.MATRIX = [DMI_W2GJ.MATRIX;zeros(8*16*8,1)];
            end
            DMI_WKK.writeToFile(fid);
            
            if obj.tunnel_walls
               mni.printing.bdf.writeComment('Tunnel Walls',fid)
               nodes = gen.octagon_nodes(1.524,2.1336,0.6146,...
                   'FilletAngle',32,'origin',[0,-1.524/2]);
               nodes = [repmat(-2,8,1),nodes];
               nodes(end+1,:) = nodes(1,:);
               pid = 102001;
               for i = 1:size(nodes,1)-1
                   mni.printing.cards.PAERO1(pid).writeToFile(fid)
                   mni.printing.cards.CAERO1(pid,pid,nodes(i,:),...
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
            mni.printing.bdf.writeFileStamp(fid);
            mni.printing.bdf.writeColumnDelimiter(fid,'8');
    
            elements = obj.gen_elements();            
            
            for i = 1:length(elements)
                elements{i}.writeToFile(fid)
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
            mni.printing.bdf.writeFileStamp(fid);
            mni.printing.bdf.writeComment('this file contains the Hinge data for teh FWT WT Model',fid)
            mni.printing.bdf.writeColumnDelimiter(fid,'8');
            fl_cards = [{mni.printing.cards.GRID(208,[0,0,0],'CP',3,'CD',3)},...
                {mni.printing.cards.GRID(209,[0,0,0],'CP',3,'CD',3)}];
            if obj.Locked
                fl_cards = [fl_cards,{mni.printing.cards.RBE2(300,208,123456,209)}];
            else
                fl_cards = [fl_cards,...
                    {mni.printing.cards.RJOINT(251,208,209,'CB','12356')},...
                    {mni.printing.cards.CBUSH(103,13,208,209,'CID',3)},...
                    {mni.printing.cards.PBUSH(13,'K',[0,0,0,hingeStiffness,0,0])},...
                    {mni.printing.cards.MOMENT(12,209,Moment,[1,0,0],'CID',3)}];
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
            C_wing = mni.printing.cards.CORD2R.FromRMatrix(1,[0,0,0],wing_rot_m);
            C_wingtip = mni.printing.cards.CORD2R.FromRMatrix(2,obj.origin,fwt_rot_m);
            C_hinge = mni.printing.cards.CORD2R.FromRMatrix(3,obj.origin,hinge_rot_m);
            C_aero = mni.printing.cards.CORD2R.FromRMatrix(4,obj.origin,aero_fwt_rot_m);          
            
            % return elements
            elements = [{C_wing},{C_wingtip},...
                {C_hinge},{C_aero}];
        end
        function vec = fwt_normal_vector(obj)
            % create transformation matricies
            wing_rot_m = roty(obj.root_aoa);
            hinge_rot_m = wing_rot_m*rotz(-obj.flare_angle);
            fwt_rot_m = hinge_rot_m*rotx(obj.fold_angle)*rotz(obj.flare_angle);
            vec = fwt_rot_m*[0,0,1]';
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