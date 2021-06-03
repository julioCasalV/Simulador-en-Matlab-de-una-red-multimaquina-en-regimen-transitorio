function dynamic_system(redNodal, redGenerador, datosIniciales, matrizAdm, redProteccion)
T=0.0002;
w0 = datosIniciales.w0;
redGenerador = redGenerador.setPm(matrizAdm, redNodal);
Gr = matrizAdm.Gr;
Br = matrizAdm.Br;
numIter = datosIniciales.totalTime/T + 1;
Enorm=zeros(1,redGenerador.count);
E=zeros(redGenerador.count,1);
Pm=zeros(1,redGenerador.count);
H=zeros(1,redGenerador.count);
D=zeros(1,redGenerador.count);
U=zeros(numIter,redNodal.count);
Eangl=zeros(numIter,redGenerador.count);
w=zeros(numIter,redGenerador.count);
Pe=zeros(numIter,redGenerador.count);
protectionValue=zeros([numIter,redProteccion.count]);
for i=1:redProteccion.count
    protectionValue(:,i)=i;
end
h=zeros(1,numIter);
for i=1:redGenerador.count
    gen = redGenerador.listGenerador(i);
    Enorm(i) = norm(gen.E);
    Eangl(1,i) = angle(gen.E);
    Pm(i) = gen.Pm;
    Pe(1,i) = gen.Pm;
    w(1,i) = w0;
    H(i) = gen.H;
    D(i) = gen.D;
end
dotInitFalta = 0;
dotEndFalta = 0;
dotIniPro=zeros(1,0);
dotEndPro=zeros(1,0);
disp("------------------");
% format shortEng
% format compact
U(1,:) = -1*pinv(matrizAdm.Y)*matrizAdm.Y21*E;
for k=1:numIter - 1
    h(k + 1)=(k)*T;
    if h(k+1) >= datosIniciales.timeIni && h(k+1) < datosIniciales.timeIni + T
        matrizAdm = matrizAdm.addCc(redNodal);
        Gr = matrizAdm.Gr;
        Br = matrizAdm.Br;
        dotInitFalta = k;
        disp("Inicio de la falta");
    end
    if h(k+1) >= datosIniciales.timeFin && h(k+1) < datosIniciales.timeFin + T
        matrizAdm = matrizAdm.dropCc(redNodal); 
        Gr = matrizAdm.Gr;
        Br = matrizAdm.Br;
        dotEndFalta = k;
        disp("Fin de la falta");
    end
    for i=1:redGenerador.count
        for r=1:redGenerador.count
            Pe(k +1, i) = Pe(k +1, i) + Enorm(i)*Enorm(r)*(Gr(i,r)*cos(Eangl(k,i)-Eangl(k,r))+Br(i,r)*sin(Eangl(k,i)-Eangl(k,r)));
        end
    end
    for i=1:redGenerador.count
        w(k + 1, i) = w(k,i) + T*w0/(2*H(i))*(Pm(i)-Pe(k + 1, i)-(D(i)*(w(k,i)-w0))/w0);
        Eangl(k + 1, i) = Eangl(k,i) + (w(k +1,i) - w0)*T;
        E(i) = Enorm(i)*(cos(Eangl(k + 1,i)) + sin(Eangl(k + 1,i))*1i);
    end
    U(k+1,:) = (-1*pinv(matrizAdm.Y)*matrizAdm.Y21*E)';
    redProteccion = redProteccion.updateProteccion(U(k+1,:)');
    upProteccion = 0;
    if redProteccion.transition == "true"
        for i=1:redProteccion.count
            proteccion = redProteccion.listProteccion(i);
            if proteccion.transition ~= 0
                if proteccion.transition < 0
                    protectionValue(k+1, i)= i + 0.5;
                    dotIniPro(end + 1) = k+1;
                else
                    protectionValue(k+1, i)=i;
                    dotEndPro(end + 1) = k+1;
                end
                upProteccion = 1;
                matrizAdm = matrizAdm.modLinea(proteccion);
                Gr = matrizAdm.Gr;
                Br = matrizAdm.Br;
            else
                protectionValue(k+1,i)=protectionValue(k,i);
            end
        end
    else
        protectionValue(k+1,:)=protectionValue(k,:);
    end
    if upProteccion == 1 || (k ~=0 && (dotInitFalta == k || dotEndFalta == k))
        disp("En el instante " + h(k + 1) + " s");
        disp("------------------");
    end
end


set(0,'DefaultLegendAutoUpdate','off');
figure('Name','Potencia frente al tiempo','NumberTitle','off');
xlabel('tiempo (s)') ;
ylabel('Potencia (p.u)');
hold on
for i=1:redGenerador.count
    nameGen = "Generador "+ redGenerador.listGenerador(i).name;
    plot(h,Pe(:,i),'DisplayName',nameGen);
end
legend('boxoff');
xline(datosIniciales.timeIni,'-.b');
xline(datosIniciales.timeFin,'-.b');
for i=1:length(dotIniPro)
        xline(h(dotIniPro(i)),":r");
end
for i=1:length(dotEndPro)
        xline(h(dotEndPro(i)),":r");
end
hold off

figure('Name','Delta frente al tiempo','NumberTitle','off');
xlabel('tiempo (s)') ;
ylabel('Delta (rad)');


hold on
genTipo1 = redGenerador.getGenTipo1(redNodal);
for i=1:redGenerador.count
    if i ~= genTipo1
        nameGen = "Generador "+ redGenerador.listGenerador(i).name;
        plot(h,Eangl(:,genTipo1) - Eangl(:,i),'DisplayName',nameGen);
    end
end
legend('boxoff');
xline(datosIniciales.timeIni,'-.b');
xline(datosIniciales.timeFin,'-.b');
for i=1:length(dotIniPro)
        xline(h(dotIniPro(i)),":r");
end
for i=1:length(dotEndPro)
        xline(h(dotEndPro(i)),":r");
end
hold off


figure('Name','W frente al tiempo','NumberTitle','off');
xlabel('tiempo (s)') ;
ylabel('Velocidad (rad/s)');
hold on
for i=1:redGenerador.count
    nameGen = "Generador "+ redGenerador.listGenerador(i).name;
    plot(h,w(:,i),'DisplayName',nameGen);
end
legend('boxoff');
xline(datosIniciales.timeIni,'-.b');
xline(datosIniciales.timeFin,'-.b');
for i=1:length(dotIniPro)
        xline(h(dotIniPro(i)),":r");
end
for i=1:length(dotEndPro)
        xline(h(dotEndPro(i)),":r");
end
hold off

figure('Name','Delta frente W','NumberTitle','off');
xlabel('Velocidad (rad/s)') ;
ylabel('Delta (rad)');
hold on
for i=1:redGenerador.count
    nameGen = "Generador "+ redGenerador.listGenerador(i).name;
    if i ~= genTipo1
        plot(w(:,i) - w0,Eangl(:,genTipo1) - Eangl(:,i),'DisplayName',nameGen);
    end
end
legend('boxoff');
for i=1:redGenerador.count
    if i ~= genTipo1
        if dotEndFalta ~= 0
            plot(w(dotInitFalta,i) - w0,Eangl(dotInitFalta,genTipo1) - Eangl(dotInitFalta,i),"ob");
            plot(w(dotEndFalta,i) - w0,Eangl(dotEndFalta,genTipo1) - Eangl(dotEndFalta,i),"xb");
        end
        if ~isempty(dotIniPro)
            plot(w(dotIniPro,i) - w0,Eangl(dotIniPro,genTipo1) - Eangl(dotIniPro,i),"xr");
        end
        if ~isempty(dotEndPro)
            plot(w(dotEndPro,i) - w0,Eangl(dotEndPro,genTipo1) - Eangl(dotEndPro,i),"*r");
        end
    end
end
hold off


figure('Name','Potencia eléctrica frente a Delta','NumberTitle','off');
xlabel('Delta (rad)') ;
ylabel('Potencia (p.u)');

hold on
for i=1:redGenerador.count
    if i ~= genTipo1
        nameGen = "Generador "+ redGenerador.listGenerador(i).name;
    	plot(Eangl(:,i) - Eangl(:,genTipo1),Pe(:,i),'DisplayName',nameGen);
    end
end
legend('boxoff');
for i=1:redGenerador.count
    if i ~= genTipo1
        if dotEndFalta ~= 0
            plot(Eangl(dotInitFalta,i) - Eangl(dotInitFalta,genTipo1),Pe(dotInitFalta,i),'ob');
            plot(Eangl(dotEndFalta,i) - Eangl(dotEndFalta,genTipo1),Pe(dotEndFalta,i),'xb');
        end
        if ~isempty(dotIniPro)
            plot(Eangl(dotIniPro,i) - Eangl(dotIniPro,genTipo1),Pe(dotIniPro,i),'xr');
        end
        if ~isempty(dotEndPro)
            plot(Eangl(dotEndPro,i) - Eangl(dotEndPro,genTipo1),Pe(dotEndPro,i),'*r');
        end
    end
end
hold off


% if redProteccion.count > 0
% 	figure('Name','Protecciones','NumberTitle','off');
% 	xlabel('tiempo(s)') ;
% 	
% 	hold on
% 	protectionLabel=strings(redProteccion.count,1);
% 	for i=1:redProteccion.count
% 	    nameProt = "Prot "+ redProteccion.listProteccion(i).name;
% 	    protectionLabel(2*i-1)=nameProt+" OFF";
% 	    protectionLabel(2*i)=nameProt+"  ON";
% 	    plot(h,protectionValue(:,i));
% 	    %,'DisplayName',nameProt
%     end
% 	ylim([0.5 ((redProteccion.count+1))]);
% 	%legend('boxoff');
% 	xline(datosIniciales.timeIni,'-.b');
% 	xline(datosIniciales.timeFin,'-.b');
% 	set(gca,'ytick',[1:0.5:(redProteccion.count+0.5)],'yticklabel',protectionLabel(:));
% 	hold off
% end

end