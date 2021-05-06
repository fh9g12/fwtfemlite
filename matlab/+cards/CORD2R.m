classdef CORD2R < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        CID;
        RID;
        A;
        B;
        C;
    end
    
    methods
        function obj = CORD2R(CID,A,B,C,varargin)
            %GRID_CARD Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser();
            p.addRequired('CID',@(x)x>0) 
            p.addRequired('A',@(x)numel(x)==3)
            p.addRequired('B',@(x)numel(x)==3)
            p.addRequired('C',@(x)numel(x)==3)
            p.addParameter('RID',0,@(x)x>=0)
            p.parse(CID,A,B,C,varargin{:})
            
            obj.Name = 'CORD2R';
            obj.CID = p.Results.CID;
            obj.RID = p.Results.RID;
            obj.A = p.Results.A;
            obj.B = p.Results.B;
            obj.C = p.Results.C;            
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{obj.CID},{obj.RID},...
                {obj.A(1)},{obj.A(2)},{obj.A(3)},...
                {obj.B(1)},{obj.B(2)},{obj.B(3)},...
                {obj.C(1)},{obj.C(2)},{obj.C(3)}];
            format = 'iirrrrrrrrr';
            obj.fprint_nas(fid,format,data);
        end
    end
    %staic constructors
    methods(Static)
        function obj = FromRMatrix(CID,origin,RMatrix,varargin)
            A = origin;
            B = RMatrix*[0 0 1]'+A;
            C = RMatrix*[1 0 0]'+A;
            obj = cards.CORD2R(CID,A,B,C,varargin{:});
        end
    end
end

