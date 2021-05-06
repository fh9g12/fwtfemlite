classdef FLUTTER < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SID;
        METHOD;
        DENS;
        MACH;
        RFREQ;
        IMETH='L';
        NMODES;
    end
    
    methods
        function obj = FLUTTER(SID,METHOD,DENS,MACH,RFREQ,NMODES)
            %FLUTTER_CARD Construct an instance of this class
            %   Detailed explanation goes here
            obj.SID = SID;
            obj.METHOD = METHOD;
            obj.DENS = DENS;
            obj.MACH = MACH;
            obj.RFREQ = RFREQ;
            obj.NMODES = NMODES;
            obj.Name = 'FLUTTER';
            
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{obj.SID},{obj.METHOD},{obj.DENS},...
                {obj.MACH},{obj.RFREQ},{obj.IMETH},{obj.NMODES}];
            format = 'isiiisi';
            obj.fprint_nas(fid,format,data);
        end
    end
end

