classdef PBush < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PID;
        K;
        B;
        GE;
        RCV;
        M;
    end
    
    methods
        function obj = PBush(PID,varargin)
            %GRID_CARD Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser();
            p.addRequired('PID',@(x)x>0)
            p.addParameter('K',[],@(x)length(x)==6)
            p.addParameter('B',[],@(x)length(x)==6)
            p.addParameter('GE',[],@(x)length(x)==6)
            p.addParameter('RCV',[],@(x)length(x)==4)
            p.addParameter('M',[],@(x)length(x)==1)
            p.parse(PID,varargin{:})
            
            obj.PID = p.Results.PID;
            obj.K = p.Results.K;
            obj.B = p.Results.B;
            obj.GE = p.Results.GE;
            obj.RCV = p.Results.RCV;
            obj.M = p.Results.M;            
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{'PBUSH'},{obj.PID}];
            format = 'si';
            if ~isempty(obj.K)
                data = [data,{'K'}];
                format = [format,'s'];
                for i = 1:length(obj.K)
                    if obj.K(i) == 0
                        format = [format,'b'];
                    else
                        data = [data,{obj.K(i)}];
                        format = [format,'f'];
                    end
                end
                format = [format,'b'];
            end
            if ~isempty(obj.B)
                data = [data,{'B'}];
                format = [format,'s'];
                for i = 1:length(obj.B)
                    if obj.B(i) == 0
                        format = [format,'b'];
                    else
                        data = [data,{obj.B(i)}];
                        format = [format,'f'];
                    end
                end
                format = [format,'b'];
            end
            if ~isempty(obj.GE)
                data = [data,{'GE'}];
                format = [format,'s'];
                for i = 1:length(obj.GE)
                    if obj.GE(i) == 0
                        format = [format,'b'];
                    else
                        data = [data,{obj.GE(i)}];
                        format = [format,'f'];
                    end
                end
                format = [format,'b'];
            end
            if ~isempty(obj.RCV)
                data = [data,{'RCV'}];
                format = [format,'s'];
                for i = 1:length(obj.RCV)
                    if obj.RCV(i) == 0
                        format = [format,'b'];
                    else
                        data = [data,{obj.RCV(i)}];
                        format = [format,'f'];
                    end
                    format = [format,'f'];
                end
                format = [format,'nb'];
            end
            if ~isempty(obj.M)
                data = [data,{'M'},{obj.M}];
                format = [format,'sf'];
            end
            if endsWith(format,'b')
                format = format(1:end-1);
            end
            
            obj.fprint_nas(fid,format,data);
        end
    end
end

