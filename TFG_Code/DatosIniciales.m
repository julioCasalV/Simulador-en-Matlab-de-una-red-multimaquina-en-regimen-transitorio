classdef DatosIniciales
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SBase;
        totalTime;
        timeIni;
        timeDuration;
        lineaCc;
        longt;
        nodoCc;
        timeFin;
        w0;
    end
    
    methods
        function obj = DatosIniciales(vector)
            %UNTITLED2 Construct
            obj.SBase = vector(1);
            obj.totalTime = vector(2);
            obj.timeIni = vector(3);
            obj.timeDuration = vector(4);
            obj.lineaCc = vector(5);
            obj.longt = vector(6);
            obj.timeFin = obj.timeIni + obj.timeDuration;
            obj.w0=2*pi*50;
        end
    end
end

