classdef CBush < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EID;
        PID;
        GA;
        GB=[];
        G0=[];
        X1=[];
        X2=[];
        X3=[];
        CID=[];
        
        vectorType;
    end
    
    methods
        function obj = CBush(EID,PID,GA,GB,varargin)
            %GRID_CARD Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser();
            p.addRequired('EID',@(x)x>0)
            p.addRequired('PID',@(x)x>0)
            p.addRequired('GA',@(x)x>0)
            p.addOptional('GB',[],@(x)x>=0)
            p.addParameter('X',[],@(x)numel(x)==3)
            p.addParameter('G0',[],@(x)x>0)
            p.addParameter('CID',[],@(x)x>0)
           
            p.parse(EID,PID,GA,GB,varargin{:})
            
            obj.EID = p.Results.EID;
            obj.PID = p.Results.PID;
            obj.GA = p.Results.GA;
            obj.GB = p.Results.GB;
            obj.CID = p.Results.CID;
            
            if ~isempty(p.Results.CID)
                obj.CID = p.Results.CID;
                obj.vectorType = 'cid';
            else            
                if xor(isempty(p.Results.G0),isempty(p.Results.X))
                    if ~isempty(p.Results.G0)
                        obj.G0 = p.Results.G0;
                        obj.vectorType = 'g0';
                    else
                        obj.X1 = p.Results.X(1);
                        obj.X2 = p.Results.X(2);
                        obj.X3 = p.Results.X(3);
                        obj.vectorType = 'x';
                    end
                else
                    error('Either G0 or Xn is defined in CBUSH Element not both')
                end   
            end
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            data = [{'CBUSH'},{obj.EID},{obj.PID},{obj.GA},{obj.GB}];
            format = 'siiii';
            switch obj.vectorType
                case 'g0'
                    data = [data,{obj.G0}];
                    format = [format,'ibbb'];
                case 'x'
                    data = [data,{obj.G0}];
                    format = [format,'ibbb'];
                case 'cid'
                    data = [data,{obj.CID}];
                    format = [format,'bbbi'];
            end            
            obj.fprint_nas(fid,format,data);
        end
    end
end

