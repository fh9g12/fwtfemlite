classdef MOMENT < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SID;
        G;
        CID;
        M;
        N1;
        N2;
        N3;
    end
    
    methods
        function obj = MOMENT(SID,G,M,N,varargin)
            %GRID_CARD Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser();
            p.addRequired('SID')
            p.addRequired('G')
            p.addRequired('M')
            p.addRequired('N',@(x)numel(x)==3)
            p.addParameter('CID','',@(x)x>=0)
            p.parse(SID,G,M,N,varargin{:})
            
            obj.Name = 'MOMENT';
            obj.SID = p.Results.SID;
            obj.G = p.Results.G;
            obj.N1 = p.Results.N(1);
            obj.N2 = p.Results.N(2);
            obj.N3 = p.Results.N(3);
            obj.M = p.Results.M;
            obj.CID = p.Results.CID;          
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{obj.SID},{obj.G},{obj.CID},{obj.M},...
                {obj.N1},{obj.N2},{obj.N3}];
            format = 'iiiffff';
            obj.fprint_nas(fid,format,data);
        end
    end
end

