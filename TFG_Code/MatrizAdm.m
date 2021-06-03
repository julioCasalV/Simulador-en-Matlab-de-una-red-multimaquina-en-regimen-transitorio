classdef MatrizAdm
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Y
        Y11
        Y12
        Y21
        Yampl
        Yr
        G
        B
        Gr
        Br
        NodoSingular
    end
    
    methods
        function obj = MatrizAdm(redNodal,redLineal)
            Y = zeros(redNodal.count, redNodal.count);
            for i=1:redLineal.count
                lineaTmp = redLineal.listLinea(i);
                coord1 = redNodal.getNodoByName(lineaTmp.nodoIni);
                coord2 = redNodal.getNodoByName(lineaTmp.nodoFin);
                Y(coord1,coord2) = Y(coord1,coord2) - 1/(lineaTmp.R + lineaTmp.X*1i);
                Y(coord2,coord1) = Y(coord1,coord2);
                Y(coord1,coord1) = Y(coord1,coord1) + (1/(lineaTmp.R + lineaTmp.X*1i) + lineaTmp.B*1i);
                Y(coord2,coord2) = Y(coord2,coord2) + (1/(lineaTmp.R + lineaTmp.X*1i) + lineaTmp.B*1i);
            end
            obj.Y = Y;
            obj.NodoSingular = zeros(redNodal.count, 1);
        end
        
        function obj = generateMarizAmpl(obj,redNodal,redGenerador)
            obj.Y11=zeros(redGenerador.count,redGenerador.count);
            obj.Y12=zeros(redGenerador.count,redNodal.count);
            obj.Y21=zeros(redNodal.count,redGenerador.count);

            for i=1:redGenerador.count
                obj.Y11(i,i)=1/(redGenerador.listGenerador(i).Xt*1i);
                coord = redNodal.getNodoByName(redGenerador.listGenerador(i).nodo);
                obj.Y(coord,coord)=obj.Y(coord,coord)+obj.Y11(i,i);
                obj.Y12(i,coord)=-obj.Y11(i,i);
                obj.Y21(coord,i)=obj.Y12(i,coord);
            end

            for i=1:redNodal.count
                 nodo = redNodal.listNodo(i);
                 obj.Y(i,i) = obj.Y(i,i) + (nodo.Pd-nodo.Qd*1i)/(nodo.U*conj(nodo.U));
            end
            obj.Yampl = [obj.Y11 obj.Y12; obj.Y21 obj.Y];
            obj = obj.setGB();
        end
        
        function obj = setGB(obj)
            obj.G = real(obj.Y);
            obj.B = imag(obj.Y);
        end
        
        function obj = setGrBr(obj)
            obj.Gr = real(obj.Yr);
            obj.Br = imag(obj.Yr);
        end
        
        function obj = generateMarizRed(obj)
            obj.Yr = obj.Y11-obj.Y12/obj.Y*obj.Y21;
            obj = obj.setGrBr();
        end
        
        function obj = modLinea(obj, proteccion)
            nodoIni = proteccion.nodoIni;
            nodoFin = proteccion.nodoFin;
            adm = proteccion.Y;
            trans = proteccion.transition;
            if obj.NodoSingular(nodoIni) == 1
                obj.Y(nodoIni,nodoIni) = 0;
                obj.NodoSingular(nodoIni) = 0;
            end
            if obj.NodoSingular(nodoFin) == 1
                obj.Y(nodoFin,nodoFin) = 0;
                obj.NodoSingular(nodoFin) = 0;
            end
            obj.Y(nodoIni,nodoFin)=obj.Y(nodoIni,nodoFin)-adm*trans;
            obj.Y(nodoFin,nodoIni)=obj.Y(nodoFin,nodoIni)-adm*trans;
            obj.Y(nodoIni,nodoIni)=obj.Y(nodoIni,nodoIni)+adm*trans;
            obj.Y(nodoFin,nodoFin)=obj.Y(nodoFin,nodoFin)+adm*trans;
            if sum(abs(obj.Y(nodoIni,nodoIni))) == 0
                disp("Alert MatrizAdm modLinea");
                obj.Y(nodoIni,nodoIni) = 1;
                obj.NodoSingular(nodoIni) = 1;
            end
            if sum(abs(obj.Y(nodoFin,nodoFin))) == 0
                disp("Alert2 MatrizAdm modLinea");
                obj.Y(nodoFin,nodoFin) = 1;
                obj.NodoSingular(nodoFin) = 1;
            end
            obj.Yampl=[obj.Y11 obj.Y12; obj.Y21 obj.Y];
            obj.Yr = obj.Y11-obj.Y12/obj.Y*obj.Y21;
            obj = obj.setGB();
            obj = obj.setGrBr();
        end
        
        function obj = addCc(obj, redNodal)
            coord = redNodal.getNodoByName(redNodal.nodoCc);
            if obj.NodoSingular(coord) == 1
                obj.Y(coord,coord) = 0;
                obj.NodoSingular(coord) = 0;
                disp("[MatrizAdm]addCc: "+coord);
            end
            obj.Y(coord,coord)=obj.Y(coord,coord)+10^9;
            obj.Yampl=[obj.Y11 obj.Y12; obj.Y21 obj.Y];
            obj.Yr = obj.Y11-obj.Y12/obj.Y*obj.Y21;
            obj = obj.setGB();
            obj = obj.setGrBr();
        end
        
        function obj = dropCc(obj, redNodal)
            coord = redNodal.getNodoByName(redNodal.nodoCc);
            obj.Y(coord,coord)=obj.Y(coord,coord)-10^9;
            if sum(abs(obj.Y(coord,:))) == 0
                obj.Y(coord,coord) = 1;
                obj.NodoSingular(coord) = 1;
                disp("[MatrizAdm]dropCC: "+coord);
            end
            obj.Yampl=[obj.Y11 obj.Y12; obj.Y21 obj.Y];
            obj.Yr = obj.Y11-obj.Y12*pinv(obj.Y)*obj.Y21;
            obj = obj.setGB();
            obj = obj.setGrBr();
        end
    end
end

