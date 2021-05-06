classdef CAERO1 < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EID;
        PID;
        CP;
        NSPAN;
        NCHORD;
        LSPAN;
        LCHORD;
        IGID;
        P1;
        P4;
        X12;
        X43;
    end
    
    methods
        function obj = CAERO1(EID,PID,P1,P4,X12,X43,IGID,varargin)
            %CAERO1 Construct an instance of this class
            %   required inputs are as follows:
            % EID - element identification
            % PID - Property Indetification of PAERO
            % P1 - 3x1 vector of point 1
            % P4 - 3x1 vector of point 4
            % X12 - edge chord length at P1
            % X34 - edge chord length at P4
            % IGID - interferance group identification
            %
            % optional parameters are
            % CP - coordinate system ID
            % NSPAN - number of spanwise panels
            % NCHORD - number of chordwise panels
            % LSPAN - ID for AEFACT for spanwise panels
            % LCHORD - ID for AEFACT for chordwise panels
            %
            % see NASTRAN users guide for more info
            p = inputParser();
            p.addRequired('EID')
            p.addRequired('PID')
            p.addRequired('P1',@(x)numel(x)==3)
            p.addRequired('P4',@(x)numel(x)==3)
            p.addRequired('X12')
            p.addRequired('X43')
            p.addRequired('IGID')
            p.addParameter('CP',0,@(x)x>=0)
            p.addParameter('NSPAN',[],@(x)x>0)
            p.addParameter('NCHORD',[],@(x)x>0)
            p.addParameter('LSPAN',[],@(x)x>0)
            p.addParameter('LCHORD',[],@(x)x>0)
            
            p.parse(EID,PID,P1,P4,X12,X43,IGID,varargin{:})
            
            names = fieldnames(p.Results);
            for i = 1:length(names)
                obj.(names{i}) = p.Results.(names{i});
            end   
            obj.Name = 'CAERO1';
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{obj.EID},{obj.PID},{obj.CP},...
                {obj.NSPAN},{obj.NCHORD},{obj.LSPAN},{obj.LCHORD},...
                {obj.IGID},{obj.P1(1)},{obj.P1(2)},{obj.P1(3)},...
                {obj.X12},{obj.P4(1)},{obj.P4(2)},{obj.P4(3)},{obj.X43}];
            format = 'iiiiiiiiffffffff';
            obj.fprint_nas(fid,format,data);
        end
    end
end

