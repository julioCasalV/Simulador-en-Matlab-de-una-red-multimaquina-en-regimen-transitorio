classdef RedLineal
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        listLinea;
        count;
        lineaCc;
        lineaAdd;
    end
    
    methods
        function  obj = addLinea(obj, vectorLinea)
            linea = Linea();
            obj.count = obj.count + 1;
            linea = linea.createLinea(obj.count, vectorLinea);
            obj.listLinea(obj.count) = linea;
        end
        
        function  obj = RedLineal()
            tmp(1)=Linea();
            obj.listLinea = tmp;
            obj.count = 0;
            obj.lineaAdd = 0;
        end
        
        function coord = getLineaByName(obj, num)
            coord = 0;
            for i=1:obj.count
                if num == obj.listLinea(i).name
                    coord = i;
                end
            end
        end
        
        function obj = addLineaCc(obj,datosIniciales,redNodal)
            coord = obj.getLineaByName(datosIniciales.lineaCc);
            obj.lineaCc = datosIniciales.lineaCc;
            obj.listLinea(coord).lineaCc = "true";
            if datosIniciales.longt ~= 0 && datosIniciales.longt ~= 1
                obj = obj.createNewLineaCc(datosIniciales,redNodal);
            end
        end
        
        function lineaCc = getLineaOrigCc(obj)
            lineaCc = obj.listLinea(obj.getLineaByName(obj.lineaCc));
            if obj.lineaAdd ~= 0
                lineaCcAdd = obj.listLinea(obj.getLineaByName(obj.lineaAdd));
                lineaCc.nodoFin = lineaCcAdd.nodoFin;
                lineaCc.R = lineaCc.R + lineaCcAdd.R;
                lineaCc.X = lineaCc.X + lineaCcAdd.X;
                lineaCc.B = lineaCc.B + lineaCcAdd.B;
                %lineaCc.proteccFin = lineaCcAdd.proteccFin;
            end
        end
        
        function obj = createNewLineaCc(obj,datosIniciales,redNodal)
            coord = obj.getLineaByName(datosIniciales.lineaCc);
            nameNewLinea = obj.getNewName();
            obj.count = obj.count + 1;
            obj.listLinea(obj.count) = obj.listLinea(coord);
            obj.listLinea(obj.count).id = obj.count;
            obj.listLinea(obj.count).name = nameNewLinea;
            obj.listLinea(coord) = obj.listLinea(coord).modifyLinea(obj.listLinea(coord).nodoIni, redNodal.nodoCc, datosIniciales.longt);
            obj.listLinea(obj.count) = obj.listLinea(obj.count).modifyLinea(redNodal.nodoCc, obj.listLinea(obj.count).nodoFin, (1 - datosIniciales.longt));
            %obj.listLinea(coord).proteccFin = Proteccion(0, 0, "false");
            %obj.listLinea(obj.count).proteccIni = Proteccion(0, 0, "false");
            obj.listLinea(obj.count).lineaAdd = "true";
            obj.lineaAdd = obj.listLinea(obj.count).name;
        end
        
        function name = getNewName(obj)
            name = obj.listLinea(1).name;
            for i=2:obj.count
                if name < obj.listLinea(i).name
                    name = obj.listLinea(i).name;
                end
            end
            name = name + 1;
        end
        
        function obj = addProteccion(obj, vectorProt)
            coord = obj.getLineaByName(vectorProt(2));
            if obj.listLinea(coord).nodoIni == vectorProt(3)
                obj.listLinea(coord).proteccIni = Proteccion(vectorProt(1), vectorProt(4), vectorProt(5), "true");
            elseif obj.listLinea(coord).nodoFin == vectorProt(3)
                obj.listLinea(coord).proteccFin = Proteccion(vectorProt(1), vectorProt(4), vectorProt(5), "true");
            else
                display("Error in addProteccion " + vectorProt(1));
            end
        end
    end
end

