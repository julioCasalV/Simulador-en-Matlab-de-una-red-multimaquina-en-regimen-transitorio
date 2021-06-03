classdef Linea
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        name
        nodoIni
        nodoFin
        R
        X
        B
        proteccIni
        proteccFin
        lineaCc
        lineaAdd
    end
    
    methods
        function obj = createLinea(obj, id, vector)
            %UNTITLED2 Construct
            obj.id = id;
            obj.name = vector(1);
            obj.nodoIni = vector(2);
            obj.nodoFin = vector(3);
            obj.R = vector(4);
            obj.X = vector(5);
            obj.B = vector(6)/2;
            obj.lineaCc = "false";
            obj.lineaAdd = "false";
        end
        
        function obj = AddProteccion(obj, name, nodo, K, J)
            %UNTITLED2 Construct
            if nodo == obj.nodoIni
                obj.proteccIni = Proteccion(name, K, J, "true");
            else
                obj.proteccFin = Proteccion(name, K, J, "true");
            end
        end
        
        function obj = modifyLinea(obj, nodoIni, nodoFin, percentage)
            %METHOD1 Summary of this method goes here
            obj.nodoIni = nodoIni;
            obj.nodoFin = nodoFin;
            obj.R = obj.R*percentage;
            obj.X = obj.X*percentage;
            obj.B = obj.B*percentage;
        end
        
        function I = getI(obj, redNodal)
            lineaNodoIni = redNodal.listNodo(redNodal.getNodoByName(obj.nodoIni));
            lineaNodoFin = redNodal.listNodo(redNodal.getNodoByName(obj.nodoFin));
            I = (lineaNodoIni.U-lineaNodoFin.U)/(obj.R+obj.X*1i);
        end
        
        function Pperd = getPperd(obj, redNodal)
            %METHOD1 Summary of this method goes here
            Pperd = real(obj.getI(redNodal)*conj(obj.getI(redNodal))*(obj.R+obj.X*1i));
        end
        
        function Qperd = getQperd(obj, redNodal)
            %METHOD1 Summary of this method goes here
            Qperd = real(obj.getI(redNodal)*conj(obj.getI(redNodal))*(obj.R+obj.X*1i));
        end
    end
end

