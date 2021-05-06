classdef SET1 < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SID;
        IDS;
    end
    
    methods
        function obj = SET1(SID,IDS)
            %FLUTTER_CARD Construct an instance of this class
            %   Detailed explanation goes here
            obj.SID = SID;
            obj.IDS = IDS;
            obj.Name = 'SET1';
            
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            data = [{obj.SID}];
            format = 'i';
            sets = obj.split_contiguous(obj.IDS);
            function print_thru(set)
                data = [data,{set(1)},{'THRU'},{set(end)}];
                format = [format,'isi']; 
            end
            for i = 1: length(sets)
                set = sets{i};
                if length(set)>3
%                     if length(format)<6
%                         print_thru(set);
%                     elseif length(format)<8
%                         format = [format,repmat('b',1,9-length(format))];
%                         print_thru(set);
                    if mod(length(format),8)>=6
                        format = [format,repmat('b',1,8-mod(length(format),8))];
                        print_thru(set);
                    else
                        print_thru(set);
                    end
                else
                    for j = 1:length(set)
                        data(end+1) = {set(j)};
                        format(end+1) = 'i';  
                    end
                end                   
            end
            obj.fprint_nas(fid,format,data);
        end
    end
    
    methods(Static)
        function out = split_contiguous(A)
        %SPLIT_CONTIGUOUS Summary of this function goes here
        %   Detailed explanation goes here
            out = {A(1),};
            for i =2:length(A)
                if A(i)-out{end}(end) == 1
                    out{end}(end+1) = A(i);
                else
                    out{end+1} = A(i);
                end
            end
        end
    end
end

