clc
clear

%SE LEEN LOS FICHEROS DE LINEAS Y PROTECCIONES
directories = dir("../TFG_Inputs/*Ejemplo*");
disp("List of found files:");
for i=1:length(directories)
    disp("("+i+") "+directories(i).name);
end
numberFile = input('Select your test: ');
while 1
    if ~isempty(find([1:length(directories)] == numberFile, 1)) %#ok<NBRAK>
       break
    end
   numberFile = input('Your selection is incorrect, please select your test again: ');
end
path = directories(numberFile).folder;
fileName = directories(numberFile).name;
disp("Working with " + fileName);
file = path + "/" + fileName;
fid=fopen(file);
leoli='';
redNodal = RedNodal();
redLineal = RedLineal();
redGenerador = RedGenerador();
redProteccion = RedProteccion();
DprTmp = zeros(0,9);

while 1
   line = fgetl(fid);
   if ~ischar(line)
       break
   end
   if ~all(isspace(line)) && length(line) > 1 && line(1) ~= '#'
       if line(1)=='L' && line(2) == 'I' 
           leoli = "LI";                   
       elseif  line(1)== 'N' && line(2) == 'U'                   
           leoli = "NU";
       elseif line(1)=='D' && line(2) == 'I' 
           leoli = "DI";
       elseif  line(1)== 'N' && line(2) == 't'                   
           leoli = "Nt";
       elseif  line(1)== 'P' && line(2) == 'R'                   
           leoli = "PR";
       else
           if leoli == "DI"
               Ds=sscanf(line,'%f %f %f %f %f %f',6);
               datosIniciales = DatosIniciales(Ds);
           elseif leoli == "LI"
               Dli=sscanf(line,'%d %d %d %f %f %f',6);
               redLineal = redLineal.addLinea(Dli);
           elseif leoli == "NU"
               Dnu=sscanf(line,'%d %f %f %f %f %f %d',7);
               redNodal = redNodal.addNodo(Dnu);
           elseif leoli == "Nt"
               Dnt=sscanf(line,'%d %d %f %f %f',5);
               redGenerador = redGenerador.addGenerador(Dnt);
           elseif leoli == "PR"
               Dpr=sscanf(line,'%d %d %d %f %f %f %f %f %f',9);
               DprTmp(end + 1, :) = Dpr;
           end
       end
   end
end
redNodal = redNodal.addNodoCc(datosIniciales,redLineal);
redNodal = redNodal.fixPQValoresPorUnidad(datosIniciales.SBase);
redLineal = redLineal.addLineaCc(datosIniciales,redNodal);
matrizAdm = MatrizAdm(redNodal, redLineal);
for i=1:size(DprTmp,1)
    redProteccion = redProteccion.addProteccion(DprTmp(i,:), redLineal, redNodal);
end
fclose(fid);



redProteccion = redProteccion.createYmatriz(redNodal);
[redNodal, redGenerador] = flujo_potencia(redNodal, redLineal, redGenerador, matrizAdm.Y);
matrizAdm = matrizAdm.generateMarizAmpl(redNodal,redGenerador);
matrizAdm = matrizAdm.generateMarizRed();

dynamic_system(redNodal, redGenerador, datosIniciales, matrizAdm, redProteccion);

