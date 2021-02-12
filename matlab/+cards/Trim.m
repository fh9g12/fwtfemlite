classdef Trim < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SID;
        Q=0;
        MACH=0;
        ANGLEA=0;
        SIDES=0;
        ROLL=0;
        PITCH=0;
        YAW=0;
        URDD1=0;
        URDD2=0;
        URDD3=0;
        URDD4=0;
        URDD5=0;
        URDD6=0;
    end
    
    methods
        function obj = Trim(SID)
            %FLUTTER_CARD Construct an instance of this class
            %   Detailed explanation goes here
            obj.SID = SID;            
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{'TRIM'},{obj.SID},{obj.MACH},{obj.Q},...
                {'ANGLEA'},{obj.ANGLEA},{'SIDES'},{obj.SIDES},...
                {'ROLL'},{obj.ROLL},{'PITCH'},{obj.PITCH},...
                {'YAW'},{obj.YAW},{'URDD1'},{obj.URDD1},...
                {'URDD2'},{obj.URDD2},{'URDD3'},{obj.URDD3},...
                {'URDD4'},{obj.URDD4},{'URDD5'},{obj.URDD5},...
                {'URDD6'},{obj.URDD6}];
            format = 'siffsfsfbsfsfsfsfsfsfsfsfsf';
            obj.fprint_nas(fid,format,data);
        end
    end
end

