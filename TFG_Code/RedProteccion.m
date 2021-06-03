classdef RedProteccion
    
    properties
        listProteccion
        Ymatriz
        transition
        count
    end
    
    methods
        function  obj = addProteccion(obj, vectorProt, redLineal, redNodal)
            proteccion = Proteccion();
            obj.count = obj.count + 1;
            proteccion = proteccion.createProteccion(vectorProt, redLineal, redNodal);
            obj.listProteccion(obj.count) = proteccion;
        end
        
        function  obj = createYmatriz(obj, redNodal)
            obj.Ymatriz = zeros(obj.count, redNodal.count);
            for i=1:obj.count
                    obj.Ymatriz(i,obj.listProteccion(i).nodoIni) = 1;
                    obj.Ymatriz(i,obj.listProteccion(i).nodoFin) = -1;
            end
        end
            
        function  obj = RedProteccion()
            tmp(1)=Proteccion();
            obj.listProteccion = tmp;
            obj.count = 0;
            obj.transition = "false";
        end
        
        function  obj = updateProteccion(obj, U)
            obj.transition = "false";
            deltaU = obj.Ymatriz*U;
            for i = 1:obj.count
                obj.listProteccion(i) = obj.listProteccion(i).updateProteccion(deltaU(i));
                if obj.listProteccion(i).transition ~= 0
                    obj.transition = "true";
                end
            end
        end
    end
end

