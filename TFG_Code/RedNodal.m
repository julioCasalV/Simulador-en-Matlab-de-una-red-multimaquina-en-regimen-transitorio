classdef RedNodal
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        listNodo;
        count;
        nodoCc;
    end
    
    methods
        function  obj = addNodo(obj, vectorNodal)
            nodo = Nodo();
            obj.count = obj.count + 1;
            nodo = nodo.createNodo(obj.count, vectorNodal);
            obj.listNodo(obj.count) = nodo;
        end
        
        function  obj = fixPQValoresPorUnidad(obj, sBase)
            for i=1:obj.count
                obj.listNodo(i) = obj.listNodo(i).fixPQ(sBase);
            end
        end
        
        function  obj = RedNodal()
            tmp(1)=Nodo();
            obj.listNodo = tmp;
            obj.count = 0;
        end
        
        function  obj = addNodoCc(obj,datos,redLineal)
            lineaId = redLineal.getLineaByName(datos.lineaCc);
            linea = redLineal.listLinea(lineaId);
            if datos.longt == 0 || datos.longt == 1
                if datos.longt == 0
                    obj = obj.setNodoCc(linea.nodoIni,"false");
                else
                    obj = obj.setNodoCc(linea.nodoFin,"false");
                end
            else
                obj = obj.addNewNodoCc();
            end
        end
        
        function coord = getNodoByName(obj, num)
            coord = 0;
            for i=1:obj.count
                if num == obj.listNodo(i).name
                    coord = i;
                end
            end
        end
        
        function obj = setNodoCc(obj,name,nodoAdd)
            coord = obj.getNodoByName(name);
            obj.listNodo(coord).nodoCc = "true";
            obj.listNodo(coord).nodoAdd = nodoAdd;
            obj.nodoCc = name;
        end
        
        function obj = addNewNodoCc(obj)
            name = obj.getNewName();
            nodo = Nodo();
            obj.count = obj.count + 1;
            nodo = nodo.createNodo(obj.count, [name 0 0 0 0 1 0 0 2]);
            obj.listNodo(obj.count) = nodo;
            obj = obj.setNodoCc(nodo.name,"true");
        end
        
        function name = getNewName(obj)
            name = obj.listNodo(1).name;
            for i=2:obj.count
                if name < obj.listNodo(i).name
                    name = obj.listNodo(i).name;
                end
            end
            name = name + 1;
        end
        
        function list = getListNodoSinBalance(obj)
            list = obj.listNodo;
            for i=1:obj.count
                if list(i).tipo == 1
                    list(i) = [];
                end
            end
        end
        
    end
end

