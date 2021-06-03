function [redNodal, redGenerador]=flujo_potencia(redNodal, redLineal, redGenerador, Y)

G=real(Y);
B=imag(Y);
iteracciones=0;
sizeJ = 0;
for i = 1:redNodal.count
    if redNodal.listNodo(i).tipo == 2
        sizeJ = sizeJ + 2;
    elseif redNodal.listNodo(i).tipo == 3
        sizeJ = sizeJ + 1;
    end
end
delta = zeros(sizeJ,1);
J = zeros(sizeJ);

% llamo h a las s en la iteración
while 1
    iteracciones=iteracciones+1;
    k = 0;
    for i=1:redNodal.count
    	nodo = redNodal.listNodo(i);
        %%Para la P
        if nodo.tipo ~= 1
            m=0;
            k=k+1;
            delta(k)=nodo.P;
            for h=1:redNodal.count
                nodoIter = redNodal.listNodo(h);
                delta(k)= delta(k) -(nodo.normU()*nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*G(i,h)+nodo.normU()*nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*B(i,h));
            end
            for s=1:redNodal.count
                %%Para el angulo de la P
                if redNodal.listNodo(s).tipo ~= 1
                    m=m+1;
                    if s==i 
                        J(k,m)=0;
                        for h=1:redNodal.count
                            if h~=i
                                nodoIter = redNodal.listNodo(h);
                                J(k,m)=J(k,m)-nodo.normU()*nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*G(i,h)+nodo.normU()*nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*B(i,h);
                            end
                        end
                    else
                        nodoIter = redNodal.listNodo(s);
                        J(k,m)= nodo.normU()*nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*G(i,s)-nodo.normU()*nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*B(i,s);
                    end
                end
                %%Para la U de la P
                if redNodal.listNodo(s).tipo == 2
                    m=m+1;
                    if s==i
                        J(k,m)=2*nodo.normU()*G(i,i);
                        for h=1:redNodal.count
                            if h~=i
                            	nodoIter = redNodal.listNodo(h);
                                J(k,m)=J(k,m)+nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*G(i,h)+nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*B(i,h);%% los apuntes son los dos cos
                            end
                        end
                    else
                    	nodoIter = redNodal.listNodo(s);
                        J(k,m)=nodo.normU()*cos(nodo.angU()-nodoIter.angU())*G(i,s)+nodo.normU()*sin(nodo.angU()-nodoIter.angU())*B(i,s);
                    end
                end
            end
        end
        
        %%%%%Para las Q
        if nodo.tipo==2
            m=0;
            k=k+1;
            delta(k)=nodo.Q;
            for h=1:redNodal.count
            	nodoIter = redNodal.listNodo(h);
                delta(k)= delta(k)-(-nodo.normU()*nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*B(i,h)+nodo.normU()*nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*G(i,h));
            end
            for s=1:redNodal.count
                %% Para el angulo de la Q
                if redNodal.listNodo(s).tipo ~= 1
                    m=m+1;
                    if s==i
                        J(k,m)=0;
                        for h=1:redNodal.count
                            if h~=i
                            	nodoIter = redNodal.listNodo(h);
                                J(k,m)=J(k,m)+nodo.normU()*nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*B(i,h)+nodo.normU()*nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*G(i,h);
                            end
                        end
                    else
                    	nodoIter = redNodal.listNodo(s);
                        J(k,m)=-nodo.normU()*nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*B(i,s)-nodo.normU()*nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*G(i,s);
                    end
                end
                %%%Para la U de Q
                if redNodal.listNodo(s).tipo==2
                    m=m+1;
                    if s==i
                        J(k,m)=-2*nodo.normU()*B(i,i);
                        for h=1:redNodal.count
                            if h~=i
                            	nodoIter = redNodal.listNodo(h);
                                J(k,m)=J(k,m)-nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*B(i,h)+nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*G(i,h);
                            end
                        end
                    else
                    	nodoIter = redNodal.listNodo(s);
                        J(k,m)=-nodo.normU()*cos(nodo.angU()-nodoIter.angU())*B(i,s)+nodo.normU()*sin(nodo.angU()-nodoIter.angU())*G(i,s);
                    end
                end
            end
        end
    end
    k=0;
    delta=J\delta;
    
    for i=1:redNodal.count
        nodo = redNodal.listNodo(i);
        if  nodo.tipo ~= 1
            k=k+1;
            redNodal.listNodo(i) = redNodal.listNodo(i).setAngU(nodo.angU()+delta(k));
        end
        if nodo.tipo == 2
            k=k+1;
            redNodal.listNodo(i) = redNodal.listNodo(i).setNormU(nodo.normU()+delta(k));
        end
    end
    
    if norm(delta) < 10^-12 || iteracciones > 10
        break
    end
end


for i=1:redNodal.count
    nodo = redNodal.listNodo(i);
    if nodo.tipo==1 
        redNodal.listNodo(i).P=0;
        for h=1:redNodal.count
            nodoIter = redNodal.listNodo(h);
            redNodal.listNodo(i).P=redNodal.listNodo(i).P + nodo.normU()*nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*G(i,h)+nodo.normU()*nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*B(i,h);
        end  
    end
    if nodo.tipo==3 || nodo.tipo==1
        redNodal.listNodo(i).Q=0;
        for h=1:redNodal.count
            nodoIter = redNodal.listNodo(h);
            redNodal.listNodo(i).Q = redNodal.listNodo(i).Q - nodo.normU()*nodoIter.normU()*cos(nodo.angU()-nodoIter.angU())*B(i,h)+nodo.normU()*nodoIter.normU()*sin(nodo.angU()-nodoIter.angU())*G(i,h);
        end
    end
end


redGenerador = redGenerador.setEI(redNodal);

f_t=fopen('../TFG_Outputs/flujo_de_potencia.txt','w');
fprintf(f_t,'                            FLUJO DE POTENCIA \n\n\n\n');
fprintf(f_t,'      De los generadores\n');
fprintf(f_t,'Generador     E norm           Eanlge           Inorm          Iangle          Pintg          Qintg \n');
for i=1:redGenerador.count
    gen = redGenerador.listGenerador(i);
    P=real(gen.E*conj(gen.I));
    Q=imag(gen.E*conj(gen.I));
    angleE=angle(gen.E)/pi*180;
    fprintf(f_t,'    %d         %f         %f        %f       %f        %f        %f        \n',gen.id,norm(gen.E),angleE,norm(gen.I),angle(gen.I),P,Q);
end



fprintf(f_t,'\n\n\n      De los nudos \n');
fprintf(f_t,'Nudo      U norm         U angle        Pg              Qg ');
for i=1:redNodal.count
    nodo = redNodal.listNodo(i);
    if nodo.nodoAdd == "false"
        angleU = angle(nodo.U)/pi*180;
        fprintf(f_t,'\n %d        %f       %f       %f        %f        %f  \n',nodo.id,norm(nodo.U),angleU,nodo.P,nodo.Q);
    end
end



fprintf(f_t,'\n\n\n      De las líneas \n');
fprintf(f_t,'Linea      Nudo_inic     Nudo_fin       Inorm        Iangle          Pperd         Qperd \n');
for i=1:redLineal.count
    linea = redLineal.listLinea(i);
    if linea.lineaAdd == "false"
        if linea.lineaCc == "true"
            linea = redLineal.getLineaOrigCc();
        end
        Iangle = angle(linea.getI(redNodal))/pi*180;
        fprintf(f_t,'  %d         %d              %d            %f     %f     %f      %f \n',linea.name,linea.nodoIni,linea.nodoFin,norm(linea.getI(redNodal)),Iangle,linea.getPperd(redNodal),linea.getQperd(redNodal));
    end
end
fclose(f_t);

end