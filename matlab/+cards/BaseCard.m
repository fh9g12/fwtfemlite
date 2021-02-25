classdef BaseCard
    %BASECARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = BaseCard()
            %BASECARD Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function writeToFile(obj,fid)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            error('Method Not Implemented')
        end
    end
    
    methods(Static)
        function fprint_nas(fid,format,data)
            data_index = 1;
            column_count = 0;
            str = '';
            for i = 1:length(format)
                switch format(i)
                    case 's'
                        if isempty(data{data_index})
                            str = [str,sprintf('%-8s','')];
                        else
                            str = [str,sprintf('%-8s',data{data_index})];                           
                        end
                        data_index = data_index + 1;
                        column_count = column_count + 1;
                    case 'i'
                        if isempty(data{data_index})
                            str = [str,sprintf('%-8s','')];
                        else
                            str = [str,sprintf('%-8i',data{data_index})];                           
                        end                 
                        data_index = data_index + 1;
                        column_count = column_count + 1;
                    case 'f'
                        if isempty(data{data_index})
                            str = [str,sprintf('%-8s','')];
                        else
                            str = [str, awi.fe.FEBaseClass.num2nasSFFstr(data{data_index})];                          
                        end 
                        data_index = data_index + 1;
                        column_count = column_count + 1;
                    case 'b'
                        str = [str,sprintf('%-8s','')];
                        column_count = column_count + 1;
                end
                if (column_count == 9) || (format(i)=='n')
                    str = [str,'\r\n'];
                    if i<length(format)
                        str = [str,sprintf('%-8s','')];
                        column_count = 1;
                    end        
                end       
            end
            if ~endsWith(str,'\r\n')
                str = [str,'\r\n'];
            end
            fprintf(fid,str);
        end
    end
end

