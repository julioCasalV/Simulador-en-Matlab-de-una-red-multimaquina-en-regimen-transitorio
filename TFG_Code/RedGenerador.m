classdef RedGenerador
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        listGenerador;
        count;
    end
    
    methods
        function  obj = addGenerador(obj, vectorGenerador)
            generador = Generador();
            generador = generador.createGenerador(vectorGenerador);
            obj.count = obj.count + 1;
            generador.id = obj.count;
            obj.listGenerador(generador.id) = generador;
        end
        
        function  obj = RedGenerador()
            tmp(1)=Generador();
            obj.listGenerador = tmp;
            obj.count = 0;
        end
        
        function  obj = setEI(obj,redNodal)
            for i = 1:obj.count
                coord = redNodal.getNodoByName(obj.listGenerador(i).nodo);
                obj.listGenerador(i) = obj.listGenerador(i).setEI(redNodal.listNodo(coord));
            end
        end
        
        function coord = getGeneradorByNodo(obj, num)
            coord = 0;
            for i=1:obj.count
                if num == obj.listGenerador(i).nodo
                    coord = i;
                end
            end
        end
        
        function obj = setPm(obj, matrizAdm, redNodal)
            for i=1:obj.count
%                 coord = redNodal.getNodoByName(obj.listGenerador(i).nodo);
                obj.listGenerador(i) = obj.listGenerador(i).setPm(obj, matrizAdm, i);
            end
        end
        
        function coord = getGenTipo1(obj, redNodal)
            coord = 0;
            for i=1:redNodal.count
                if redNodal.listNodo(i).tipo == 1
                    coord = obj.getGeneradorByNodo(redNodal.listNodo(i).name);
                end
            end
        end
    end
end

