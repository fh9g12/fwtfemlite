classdef TrimParameter
    %TrimParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name;
        Value;
        Type;
    end
    
    methods
        function obj = TrimParameter(Name,Value,Type)
            if ~validatestring(Type,{'Rigid Body','Control Surface'})
                error('Parameter type must be either "Rigid Body" or "Control Surface" not, "%s"',Type)
            end
            obj.Name = Name;
            obj.Value = Value;
            obj.Type = Type;
        end
    end
end

