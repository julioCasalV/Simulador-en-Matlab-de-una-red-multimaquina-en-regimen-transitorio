classdef Generador
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        name
        nodo
        Xt
        H
        D
        E
        I
        w
        w0
        Pm
        Pe
    end
    
    methods
        function obj = createGenerador(obj, vector)
            %UNTITLED2 Construct
            obj.name = vector(1);
            obj.nodo = vector(2);
            obj.Xt = vector(3);
            obj.H = vector(4);
            obj.D = vector(5);
            obj.E = 0;
            obj.I = 0;
            obj.w0 = 2*pi*50;
            obj.w = obj.w0;
            obj.Pm = 0;
            obj.Pe = 0;
        end
        
        function obj = setEI(obj,nodo)
            %METHOD1 Summary of this method goes here
            nodo.P = nodo.P + nodo.Pd;
            nodo.Q = nodo.Q + nodo.Qd;
            obj.I = (nodo.P-nodo.Q*1i)/conj(nodo.U);
            obj.E = nodo.U+obj.Xt*1i*obj.I;
        end
        
        function ang = getEAngl(obj)
            %METHOD1 Summary of this method goes here
            ang = angle(obj.E);
        end
        
        function obj = setEAngle(obj, angle)
            %METHOD1 Summary of this method goes here
            obj.E = norm(obj.E)*(cos(angle)+sin(angle)*1i);
        end
        
        function obj = setPm(obj, redGenerador, matrizAdm, coord)
            %METHOD1 Summary of this method goes here
            obj.Pm = 0;
            Gr = real(matrizAdm.Yr);
            Br = imag(matrizAdm.Yr);
            for r=1:redGenerador.count
                genIter = redGenerador.listGenerador(r);
                obj.Pm=obj.Pm+norm(obj.E)*norm(genIter.E)*(Gr(coord,r)*cos(angle(obj.E)-angle(genIter.E))+Br(coord,r)*sin(angle(obj.E)-angle(genIter.E)));
            end
        end
        
    end
end

