classdef DMI < cards.BaseCard
    %FLUTTER_CARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NAME;
        MATRIX;
        FORM;
        TIN;
        TOUT;
    end
    
    methods
        function obj = DMI(NAME,MATRIX,FORM,TIN,TOUT)
            %FLUTTER_CARD Construct an instance of this class
            %   Detailed explanation goes here
            function pass = check_form(x)
                pass = any([1,2,3]==x);
                if ~pass
                   error('only matrix forms 1,2,3 are currently supported') 
                end
            end
            function pass = check_T(x,vals)
                pass = any(vals==x);
                if ~pass
                   error('only real number forms are currently supported') 
                end
            end
            p = inputParser();
            p.addRequired('NAME',@(x)ischar(x))
            p.addRequired('MATRIX',@(x)isnumeric(x))
            p.addRequired('FORM',@check_form)
            p.addRequired('TIN',@(x)check_T(x,[1,2]))
            p.addRequired('TOUT',@(x)check_T(x,[0,1,2]))
            p.parse(NAME,MATRIX,FORM,TIN,TOUT)
            
            obj.Name = 'DMI';
            obj.NAME = p.Results.NAME;
            obj.MATRIX = p.Results.MATRIX;
            obj.FORM = p.Results.FORM;
            obj.TIN = p.Results.TIN;
            obj.TOUT = p.Results.TOUT;            
        end
        
        function writeToFile(obj,fid)
            %writeToFile print DMI entry to file
            
            % write the header card to the file
            data = [{obj.NAME},{0},{obj.FORM},{obj.TIN},{obj.TOUT},...
                {size(obj.MATRIX,1)},{size(obj.MATRIX,2)}];
            format = 'siiiibii';
            obj.fprint_nas(fid,format,data);
            
            % for each column in obj.MATRIX write a corresponding data card
            s = size(obj.MATRIX);
            for j = 1:s(2)
                %write header info
                data = [{obj.NAME},{j}];
                format = 'si';               
                %initilise counters
                i = 1;
                last = 0;
                is_data = 0;
                % only print non-zero data in card
                while i <= s(1)
                    tmp = obj.MATRIX(i,j);
                    if tmp ~= 0
                        if last == 0
                            data = [data,{i},{tmp}];
                            format = [format,'if'];
                            is_data = 1;
                        elseif (last == tmp)
                            % if consecutive terms use THRU simplification
                            data = [data,{'THRU'}];
                            format = [format,'s'];
                            last = tmp;
                            while tmp == last
                                i = i+1;
                                if i > s(1)
                                    break
                                end
                                tmp = obj.MATRIX(i,j);
                            end
                            i = i-1;
                            tmp = 0;
                            data = [data,{i}];
                            format = [format,'i'];
                        else
                            data = [data,{tmp}];
                            format = [format,'f'];
                        end
                    end
                    last = tmp;
                    i = i + 1;
                end
                
                %Write the data to the file
                if is_data
                    obj.fprint_nas(fid,format,data);
                end
            end
        end
    end
end

