classdef FLFACT < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SID;
        VALUES;
    end
    
    methods
        function obj = FLFACT(SID,VALUES)
            %FLUTTER_CARD Construct an instance of this class
            %   Detailed explanation goes here
            obj.SID = SID;
            obj.VALUES = VALUES;
            
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{'FLFACT'},{obj.SID}];
            format = 'si';
            for i = 1: length(obj.VALUES)
                data(end+1) = {obj.VALUES(i)};
                format(end+1) = 'f';        
            end
            obj.fprint_nas(fid,format,data);
        end
    end
end

