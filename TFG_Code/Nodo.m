classdef Nodo
    %Nodo
    
    properties
        id
        name
        Pd
        Qd
        Pg
        Qg
        U
        tipo
        P
        Q
        nodoCc
        nodoAdd
    end
    
    methods
        function obj = createNodo(obj, count, vector)
            %UNTITLED2 Construct
            obj.id = count;
            obj.name = vector(1);
            obj.Pd = vector(2);
            obj.Qd = vector(3);
            obj.Pg = vector(4);
            obj.Qg = vector(5);
            obj.U = vector(6);
            obj.tipo = vector(7);
            obj.nodoCc = "false";
            obj.nodoAdd = "false";
        end
        
        function obj = fixPQ(obj, sBase)
            %UNTITLED2 
            obj.Pd = obj.Pd/sBase;
            obj.Pg = obj.Pg/sBase;
            obj.Qd = obj.Qd/sBase;
            obj.Qg = obj.Qg/sBase;
            obj.P = obj.Pg - obj.Pd;
            obj.Q = obj.Qg - obj.Qd;
        end
        
        function angOut = angU(obj)
            angOut = angle(obj.U);
        end
        
        function uNorm = normU(obj)
            uNorm = abs(obj.U);
        end
        
        function obj = setAngU(obj, angle)
            obj.U = obj.normU()*(cos(angle)+sin(angle)*1i);
        end
        
        function obj = setNormU(obj, norm)
            obj.U = norm*(cos(obj.angU())+sin(obj.angU())*1i);
        end
        
    end
end

