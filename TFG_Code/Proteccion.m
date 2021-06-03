classdef Proteccion
    %UNTITLED12 Summary of this class goes here
    
    properties
        name
        linea
        time
        K
        J
        energized
        coefA
        coefB
        coefC
        resetTime
        nodoIni
        nodoFin
        Y
        transition
    end
    
    methods
        function  obj = createProteccion(obj, vectorProt, redLineal, redNodal)
            obj.name = vectorProt(1);
            obj.linea = vectorProt(2);
            if vectorProt(3) == 2 && obj.linea == redLineal.lineaCc && redLineal.lineaAdd ~= 0
                 obj.linea = redLineal.lineaAdd;
            end
            obj.J = vectorProt(4);
            obj.K = vectorProt(5);
            obj.coefA =  vectorProt(6);
            obj.coefB =  vectorProt(7);
            obj.coefC =  vectorProt(8);
            obj.resetTime = vectorProt(9);
            obj.energized = "false";
            obj.time = 0;
            obj.transition = 0;
            lineaTmp = redLineal.listLinea(redLineal.getLineaByName(obj.linea));
            obj.Y = 1/(lineaTmp.R + lineaTmp.X*1i);
            if vectorProt(3) == 1
                obj.nodoIni = redNodal.getNodoByName(lineaTmp.nodoIni);
                obj.nodoFin = redNodal.getNodoByName(lineaTmp.nodoFin);
            else
                obj.nodoIni = redNodal.getNodoByName(lineaTmp.nodoFin);
                obj.nodoFin = redNodal.getNodoByName(lineaTmp.nodoIni);
            end
        end
        
        function  obj = updateProteccion(obj, deltaU)
            obj.transition = 0;
            I = deltaU*obj.Y;
            angI = norm(angle(I));
            tResult = obj.K*(obj.coefA / ((norm(I)/obj.J)^obj.coefB - 1) + obj.coefC);
            if (angI > pi/2 || tResult <= 0) && obj.energized == "false"
                obj.time = 0;
            else
                obj.time = obj.time + 0.0002;
                if obj.energized == "false" && angI < pi/2 && tResult < obj.time
                    disp("Proteccion <strong>ON: " + obj.name + "</strong> con intensidad: " + norm(I) + " p.u");
                    obj.time = 0;
                    obj.energized = "true";
                    obj.transition = -1;
                elseif obj.energized == "true" && obj.time >= obj.resetTime
                    disp("Proteccion <strong>OFF: " + obj.name + "</strong> ");
                    obj.energized = "false";
                    obj.time = 0;
                    obj.transition = 1;
                end
            end
        end
        
    end
end

