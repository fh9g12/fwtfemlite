classdef SPLINE4 < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EID;
        CAERO;
        AELIST;
        SETG;
        DZ;
        METH;
        USAGE;
    end
    
    methods
        function obj = SPLINE4(EID,varargin)
            %GRID_CARD Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser();
            p.addRequired('EID',@(x)x>0)
            p.addParameter('CAERO',[],@(x)x>0)
            p.addParameter('AELIST',[],@(x)x>0)
            p.addParameter('SETG',[],@(x)x>0)
            p.addParameter('DZ',[],@(x)x>=0)
            p.addParameter('METH',[],@(x)any(validatestring(x,...
                {'IPS','TPS','FPS','RIS'})))
            p.addParameter('USAGE',[],@(x)any(validatestring(x,...
                {'FORCE','DISP','BOTH'})))
            p.parse(EID,varargin{:})
            
            obj.EID = p.Results.EID;
            obj.CAERO = p.Results.CAERO;
            obj.AELIST = p.Results.AELIST;
            obj.SETG = p.Results.SETG;
            obj.DZ = p.Results.DZ;
            obj.METH = p.Results.METH;
            obj.USAGE = p.Results.USAGE; 
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{'SPLINE4'},{obj.EID},{obj.CAERO},{obj.AELIST},...
                {obj.SETG},{obj.DZ},{obj.METH},{obj.USAGE}];
            format = 'siiibifss';
            obj.fprint_nas(fid,format,data);
        end
    end
end

