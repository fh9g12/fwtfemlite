function str = num2nasSFFstr(num,varargin)
    %NUM2NASSFFSTR converts number to NASTRAN Small or Long Field Format string
    %   num - Number to convert
    % Parameters
    %   Format (default = 'short') - either 'long or 'short'
    %
    % Created by: Fintan Healy(2021) 
    % Adapted from: Coon Timothy (2021). num2nasSFFstr( num ) 
    % (https://www.mathworks.com/matlabcentral/fileexchange/55232-num2nassffstr-num), 
    % MATLAB Central File Exchange. Retrieved February 4, 2021
    p = inputParser();
    p.addParameter('Format','short',@(x) any(validatestring(x,{'short','long'})))
    p.parse(varargin{:})
    if strcmp(p.Results.Format,'short')
        lField = 8;
    else
        lField = 16;
    end
    if num == 0
        str = sprintf(['%-',num2str(lField),'s'],'0.');
    else
        % Set lField and get first approximation for nSigFigs
        nSigFigs=lField;
        % Convert the number to a string and reduce.
        str = getReduceStr(num,nSigFigs);
        while length(str) > lField
            nSigFigs = nSigFigs - 1;
            str = getReduceStr(num,nSigFigs);
        end
        % Fill str with blank spaces to fill field as necessary
        str = sprintf(['%-',num2str(lField),'s'],str);
    end
    % nested function to get reduced str from num
    function str = getReduceStr(num,nSigFigs)
        % convert the number to a string
        str = sprintf('%-0.*G',nSigFigs,num);
        iE = regexp(str,'[E]','ONCE');
        % If there is no decimal, the string is an integer, so add one to the 
        % end (or before the E). Nastran needs a decimal to recognize a number
        if isempty(regexp(str,'[.]','ONCE'))
            if isempty(iE)
                str = [str '.'];
            else 
                str =[str(1:iE-1) '.' str(iE:end)];
                iE = regexp(str,'[E]','ONCE');
            end
        end
        % Remove unnecessary zeros
        % 000.XXX -> .XXX % remove leading zeros
        str = regexprep(str,'^0+','');
        % X.XE+0X -> X.X+X % remove leading zeros, and the 'E' in the exponential
        str = regexprep(str,'E([\+,\-])0*','$1');
    end
end

