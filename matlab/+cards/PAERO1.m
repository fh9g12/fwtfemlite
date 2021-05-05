classdef PAERO1 < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PID;
        B1;
        B2;
        B3;
        B4;
        B5;
        B6;
    end
    
    methods
        function obj = PAERO1(PID,varargin)
            %GRID_CARD Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser();
            p.addRequired('PID',@(x)x>0)
            p.addOptional('B1',[],@(x)x>0)
            p.addOptional('B2',[],@(x)x>0)
            p.addOptional('B3',[],@(x)x>0)
            p.addOptional('B4',[],@(x)x>0)
            p.addOptional('B5',[],@(x)x>0)
            p.addOptional('B6',[],@(x)x>0)
            p.parse(PID,varargin{:})
            
            names = fieldnames(p.Results);
            for i = 1:length(names)
                obj.(names{i}) = p.Results.(names{i});
            end               
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{'PAERO1'},{obj.PID},{obj.B1},{obj.B2},...
                {obj.B3},{obj.B4},{obj.B5},{obj.B6}];
            format = 'siiiiiii';            
            obj.fprint_nas(fid,format,data);
        end
    end
end

