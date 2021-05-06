classdef BaseCard
    %BASECARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name = '';
        LongFormat = false;
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
    
        function fprint_nas(obj,fid,format,data)
            %FPRINT_NAS print card data to file
            %   prints the card data to the file 'fid' following NASTRAN
            %   formating guidelines:
            %    - Column Width is specified by obj.Format (can be 'long'
            %         or 'short'), the correct continuation string format
            %         is also used.
            %    - the card name is specified by obj.Name
            %    - Card data is specified by 'format' and 'data' where:
            %       data - a list of cells containing teh card data
            %       format - a character array specifing the format of each
            %           item in data e.g. 'isbfi', with the following
            %           options:
            %               's'         - string
            %               'i'         - integer
            %               'f' or 'r'  - real
            %               'b'         - blank (no corresponding item in
            %                               data required)
            %               'n'         - newline
            %               
            % Author: Fintan Healy, fintan.healy@bristol.ac.uk (06/05/21) 
            if obj.LongFormat
                con_str = '*';
                col_format = '%-16';
                format_string = 'long';
            else
                con_str = '';
                col_format = '%-8';
                format_string = 'short';
            end
            %function to create blank column entry
            function str = blank_col(str)
                str = [str,sprintf([col_format,'s'],'')];
            end
            %print the Name with continuation character and start counters
            str = sprintf('%-8s',[obj.Name,con_str]);
            data_index = 1;
            column_count = 1;
            % iterate through provided format spec
            for i = 1:length(format)
                switch format(i)
                    case 's'
                        if isempty(data{data_index})
                            str = blank_col(str);
                        else
                            str = [str,sprintf([col_format,'s'],data{data_index})];                           
                        end
                        data_index = data_index + 1;
                        column_count = column_count + 1;
                    case 'i'
                        if isempty(data{data_index})
                            str = blank_col(str);
                        else
                            str = [str,sprintf([col_format,'i'],data{data_index})];                           
                        end                 
                        data_index = data_index + 1;
                        column_count = column_count + 1;
                    case {'f','r'}
                        if isempty(data{data_index})
                            str = blank_col(str);
                        else
                            str = [str, cards.num2nasSFFstr(data{data_index},'Format',format_string)];                          
                        end 
                        data_index = data_index + 1;
                        column_count = column_count + 1;
                    case 'b'
                        str = blank_col(str);
                        column_count = column_count + 1;
                end
                % if format spec says new line or maximum columns used roll
                % over onto a new line
                if (format(i)=='n') || ...
                        (~obj.LongFormat && (column_count == 9)) || ...
                        (obj.LongFormat  && (column_count == 5))
                    str = [str,'\r\n'];
                    if i<length(format)
                        str = [str,sprintf('%-8s',con_str)];
                        column_count = 1;
                    end        
                end       
            end
            % ensure the string ends with a newline
            if ~endsWith(str,'\r\n')
                str = [str,'\r\n'];
            end
            % print string to the file
            fprintf(fid,str);
        end
    end
end

