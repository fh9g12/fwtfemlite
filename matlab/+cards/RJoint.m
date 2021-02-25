classdef RJoint < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EID;
        GA;
        GB;
        CB;
    end
    
    methods
        function obj = RJoint(EID,GA,GB,varargin)
            %GRID_CARD Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser();
            p.addRequired('EID',@(x)x>0)
            p.addRequired('GA',@(x)x>0)
            p.addRequired('GB',@(x)x>0)
            p.addParameter('CB','')
            p.parse(EID,GA,GB,varargin{:})
            
            obj.EID = p.Results.EID;
            obj.GA = p.Results.GA;
            obj.GB = p.Results.GB;
            obj.CB = p.Results.CB;           
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{'RJOINT'},{obj.EID},{obj.GA},{obj.GB},{obj.CB}];
            format = 'siiis';
            obj.fprint_nas(fid,format,data);
        end
    end
end

