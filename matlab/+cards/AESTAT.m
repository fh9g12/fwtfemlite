classdef AESTAT < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID;
        LABEL;
    end
    
    methods
        function obj = AESTAT(ID,LABEL)
            %FLUTTER_CARD Construct an instance of this class
            %   Detailed explanation goes here
            obj.ID = ID;
            obj.LABEL = LABEL;
            
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{'AESTAT'},{obj.ID},{obj.LABEL}];
            format = 'sis';  
            obj.fprint_nas(fid,format,data);
        end
    end
end

