classdef TrimParameters < matlab.mixin.Copyable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ANGLEA = gen.TrimParameter('ANGLEA',0,'Rigid Body');
        SIDES = gen.TrimParameter('SIDES',0,'Rigid Body');
        PITCH = gen.TrimParameter('PITCH',0,'Rigid Body');
        ROLL = gen.TrimParameter('ROLL',0,'Rigid Body');
        YAW = gen.TrimParameter('YAW',0,'Rigid Body');
        URDD1 = gen.TrimParameter('URDD1',0,'Rigid Body');
        URDD2 = gen.TrimParameter('URDD2',0,'Rigid Body');
        URDD3 = gen.TrimParameter('URDD3',0,'Rigid Body');
        URDD4 = gen.TrimParameter('URDD4',0,'Rigid Body');
        URDD5 = gen.TrimParameter('URDD5',0,'Rigid Body');
        URDD6 = gen.TrimParameter('URDD6',0,'Rigid Body');
        
        LoadFactor = 1;
        DoFs = [];
        V = 0;
        rho = 0;
        Mach = 0;
    end
    
    methods
        function obj = TrimParameters(V,rho,Mach)
            obj.V = V;
            obj.rho = rho;
            obj.Mach = Mach;
        end
    end
    methods(Static)
        function obj = SteadyLevel(V,rho,Mach)
            obj = gen.TrimParameters(V,rho,Mach);
            obj.ANGLEA.Value = NaN;
            obj.elev1r.Value = NaN;
            obj.DoFs = 35;
        end
        function obj = Locked(V,rho,Mach)
            obj = gen.TrimParameters(V,rho,Mach);
            obj.DoFs = [];
        end
    end
end

