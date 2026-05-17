unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Buttons, StdCtrls, Grids, Spin, ColorBox, TAGraph, Math;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Chart1: TChart;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    RadioGroup1: TRadioGroup;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    procedure cargarDatosLimpios(fils, cols: integer);
    procedure calcularProbabilidadesApr();
    procedure probabilidadesAtributoNum(columna: integer);
    procedure probabilidadesAtributoNom(columna: integer);
    procedure naiveBayesEntrenamientoT();

    function calcularDensidad(x, media, desvE: real): real;
    function probNominal(col, clase, x: integer): real;
    {para esta usamos extrañamente un array of string porque no sé que vaya a
    caer, si integer o real, mejro convertirlos}
    function predictDecF(x: array of string): integer;
  public

  end;

var
  Form3: TForm3;
  {Elementos para cargar los datos, de manera global debido a que todas
  las funciones van a trabajar con estos datos. Además es un módulo aparte
  así que no lo quiero saturar tanto, de igual manera quiero que se vea un poco
  más limpio y chance modular aunque va a ser un poco más complejo. Veremos.}

  {SOLO CARGA DE DATOS}
  headers: array of integer;
  noClases: integer;
  dataSetLimpio: array of array of real;
  lastColumn: array of integer;
  contaFG: array of integer;
  {Al final parece que mejor si hago un arreglo global de contadores de las
  clases pero ya no quiero cambiarle nada al codigo asi que gg/}
  {============================================================================}
  {PROBABILIDADES}
  probaprXclase: array of real;
  {M[ETOODS PARA LA VEROSIMILITUD}
  matrizMedias: array of array of real;
  matrizDesviacionesE: array of array of real;
  {matrizFrecuencias: array of array of integer;}
  matrizFrecuenciasG: array of array of array of integer;
  {NAIVE BAYES, ENTRENAMIENTO CON EL CONJUNTO T}

implementation


{$R *.lfm}

{ TForm3 }

{------------------------------------------------------------------------------}
{Funciones para cargar los datos al stringgrid y pasarlos a arreglos que son más
manejables.}

procedure TForm3.cargarDatosLimpios(fils, cols: integer);

var
  i,j: integer;
begin
  {Ahora no pienso guardar los headers en el mismo arreglo de dataset porque
  en este módulo debido a que se siente más complejo mejor separo todo.

  Pienso mostrar en el stringgrid los datos, sin la fila de tipo de atributo
  pero si la de clases.}

  SetLength(dataSetLimpio, fils, cols);
  SetLength(headers, cols);
  SetLength(lastColumn, fils);




  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSetLimpio[i,j]:= StrToFloat(StringGrid1.Cells[j,i+1]);
    end;
  end;

  for i:=0 to cols-1 do begin
      headers[i]:= StrToInt(StringGrid1.Cells[i,0]);
  end;

  noClases:=StrToInt(StringGrid1.Cells[cols,0]); {o simplemente i-1 jaja}

  for i:=1 to fils do begin
      lastColumn[i-1]:= StrToInt(StringGrid1.Cells[cols,i]);
  end;
  setlength(contaFG, noClases);
  for i:=0 to noClases-1 do begin
      contaFG[i]:= 0;
  end;
  for i:=0 to length(lastColumn)-1 do begin
    contaFG[lastColumn[i]]:=contaFG[lastColumn[i]] + 1;
  end;

  stringgrid1.DeleteRow(0);



  {----------------------------------DEBUG-------------------------------------}
  {
   Imprimir tamaño de matriz y stringgrid
   Imprimir valores de dataSetLimpio para ver que únicamente mantenga
   instancias.
   Imprimir headers para ver que se guarde toda la primera fila.
   Imprimir número de clases que es la última columna de la primera fila.
   Imprimir la última columna para ver que guardamos todas.
  }
  {


  writeln('Matriz: ', fils, 'x', cols);
  writeln('StringGrid: ', stringgrid1.RowCount, 'x', stringgrid1.ColCount);


  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      writeln(dataSetLimpio[i,j]);
    end;
    writeln();
  end;

  for i:=0 to cols-1  do begin
      writeln(headers[i]);

  end;
  writeln(length(headers));

  writeln(noClases);

  for i:=0 to fils-1 do begin
      writeln(lastColumn[i]);

  end;
  writeln(length(lastColumn));
  }


end;

{------------------------------------------------------------------------------}
{Función para calcular P(Ci), las probabilidades a priori de todas las clases.}

procedure TForm3.calcularProbabilidadesApr();
var
  i,s: integer;
  c: real;
  contadores: array of integer;
begin
  contadores:=nil;

  setLength(contadores, noClases);
  setLength(probaprXclase, noClases);
  for i:=0 to noClases-1 do begin
      contadores[i]:= 0;
  end;

  for i:=0 to length(lastColumn)-1 do begin
    contadores[lastColumn[i]]:= contadores[lastColumn[i]]+1;
  end;

  for i:=0 to noClases-1 do begin
    probaprXclase[i]:= contadores[i] / length(dataSetLimpio);
  end;


  {----------------------------------DEBUG-------------------------------------}
  {
   Imprimir el conteo por clase.
   Imprimir número de filas.
   Imprimir probabilidades por clase;
  }
  {
  s:=0;
  for i:=0 to noClases-1 do begin
    s:= s+contadores[i];
    writeln(i,contadores[i]);
  end;
  writeln(s);

  s:=length(dataSetLimpio);
  writeln(s);

  c:=0;
  for i:=0 to noClases-1 do begin
    writeln('Probabilidad de la clase: ',i, '= ', probaprXclase[i]);
    c:=c +   probaprXclase[i];
  end;
  writeln('Suma de probabilidades: ',c);
  }


end;


{------------------------------------------------------------------------------}
{Funciones para calcular P(Xk | Ci), que es la verosimilitud de los atributos
son dos porque para valores numéricos requerimos de la media y desviación
estándar, sin embargo, para atributos nominales solo es una división inmediata.
Para ello se dividieron para no tener la lógica de las 2 metidas dentro de una
única función, solo requerimos ver el tipo de dato y mandar a llamar la correct-
a.}
{Vamos necesitar donde guardar todos los datos de medias y desviaciones que van
a salir de las columnas así que usaremos matrizMedias y matrizDesviacionesE}
procedure TForm3.probabilidadesAtributoNum(columna: integer);
var
  i,j, k: integer;
  s, s2: real;
  contadores: array of integer;
  agrupacionValores: array of array of real;
  {AGRUPA LOS VALORES FLOTANTES SEGÚN SU CLASE}

begin
  contadores:= nil;
  agrupacionValores:= nil;
  {Sabemos que Matriz medias tiene el numero de atributos que se encontraron en
  el documento cargado; Además, tiene el número de clases.}

  setlength(contadores, noClases);
  setlength(agrupacionValores, noClases);

  {
   Antes de empezar a sacar valores estadísticos tengo que agrupar que valores
   tiene cada clase, entonces creo un arreglo que tenga noclases como filas
   y cada fila debe ser un arreglo con un tamaño determinado por la cantidad de veces que
   aparezca dicha clase, eso ya lo hice en la función de arriba pero como no la hice global
   y aquí la estaré reutilizando pues mejor la vuelvo a calcular, es simple.
  }

  for i:=0 to noClases-1 do begin
      contadores[i]:= 0;
  end;


  for i:=0 to length(lastColumn)-1 do begin
    contadores[lastColumn[i]]:= contadores[lastColumn[i]] + 1;
  end;

  {Agrupamientos por clases qwq}
  for i:=0 to noClases-1 do begin
    setlength(agrupacionValores[i], contadores[i]);
    contadores[i]:=0;
  end;

  for i:=0 to length(lastColumn)-1 do begin
      agrupacionValores[lastColumn[i], contadores[lastColumn[i]]]:=dataSetLimpio[i,columna];
      Inc(contadores[lastColumn[i]]);
  end;

  {sacando medias y callando bocas}
  for i:=0 to noClases-1 do begin
    s:=0;
    for j:=0 to contadores[i]-1 do begin
        s:= s+ agrupacionValores[i,j];
    end;
    matrizMedias[columna, i]:= s / contadores[i];
  end;

  {Ya hay medias, empiezo desviaciones.}

  for i:=0 to noClases-1 do begin
    s2:=0;
    for j:=0 to contadores[i]-1 do begin
        s2:= s2+ power((agrupacionValores[i,j] - matrizMedias[columna,i]), 2);
    end;
    matrizDesviacionesE[columna, i]:= sqrt(s2 / contadores[i]);
  end;





  {
  ----------------------------------DEBUG-------------------------------------
  lastColumn[i] va de 0 a noClases - 1;
  contadores[i] va de 0 a noClases - 1
  pero contadores[i] cuando i  > noClases
  claramente no existe.


  s:=0;
  for i:=0 to noClases-1 do begin
    for j:=0 to contadores[i]-1 do begin
        WriteLn('Clase: ', i, agrupacionValores[i,j]);
        s:=s+1;
    end;
    writeLn();
  end;
  writeLn(s);


  for i:=0 to noClases-1 do begin
    s:=0;
    for j:=0 to contadores[i]-1 do begin
        s:= s+ agrupacionValores[i,j];
    end;
    matrizMedias[columna, i]:= s / contadores[i];
    writeln(s, ' / ', contadores[i], ' = ', s / contadores[i]);
  end;

  k:=0;
  for i:=0 to noClases-1 do begin
    for j:=0 to contadores[i]-1 do begin
        WriteLn('Clase: ', i, agrupacionValores[i,j]);
        k:=k+1;
    end;
    writeLn();
    writeLn(k);
    k:=0;
  end;



  s:=0;
  for i:=0 to noClases-1 do begin
      writeln('Columna: ', columna, 'Clase ', i, 'Media: ', matrizMedias[columna, i], 'Desv. E: ', matrizDesviacionesE[columna,i]);
  end;
  }


end;


{
 En este caso solo me interesa contar cuántas veces aparece cada valor nominal
 en cada una de las clases. Cuántos 0s en la clase 2, cuántos 1s, cuántos 2s,...
 entonces puedo hacer una matriz de clasesxnorespuestasnominales
 asi puedo contar por cada clase
}
procedure TForm3.probabilidadesAtributoNom(columna: integer);
var
  i,j,s: integer;


begin

  {setlength(matrizFrecuencias, noClases, headers[columna]);}
  setlength(matrizFrecuenciasG[columna], noClases, headers[columna]);


  for i:=0 to noClases-1 do begin
    for j:=0 to headers[columna]-1 do begin
      matrizFrecuenciasG[columna,i,j]:=0;
    end;
  end;

  for i:=0 to length(lastColumn)-1 do begin
    matrizFrecuenciasG[columna, lastColumn[i], round(dataSetLimpio[i,columna])]:= matrizFrecuenciasG[columna, lastColumn[i], round(dataSetLimpio[i,columna])] + 1;
  end;

{-----------------------------------DEBUG--------------------------------------
  s:=0;
  writeln('Atributo: ', columna ,' No. Respuestas: ', headers[columna]);
  for i:=0 to noClases-1 do begin
    for j:=0 to headers[columna]-1 do begin
      writeln('Frecuencia de: ', j, ' en la clase: ', i , ' = ' ,matrizFrecuencias[i,j]);
      s:=s+matrizFrecuencias[i,j];
    end;
    writeln();
  end;
  writeln(s);
  CALAJo si quedso

  Intento de agregar la dimension de las columnas
  s:=0;
  writeln('Columna: ', columna, 'Atributo: ', headers[columna] ,' No. Respuestas: ', headers[columna]);
  for i:=0 to noClases-1 do begin
    for j:=0 to headers[columna]-1 do begin
      writeln('Frecuencia de: ', j, ' en la clase: ', i , ' = ' ,matrizFrecuenciasG[columna,i,j]);
      s:=s+matrizFrecuenciasG[columna, i,j];
    end;
    writeln();
  end;
  writeln(s);
}



end;

procedure TForm3.naiveBayesEntrenamientoT();
var
  i: integer;
begin
  calcularProbabilidadesApr();
  for i:=0 to length(dataSetLimpio[0])-1 do begin
    if headers[i] = 0 then begin
       probabilidadesAtributoNum(i);
    end
    else
        probabilidadesAtributoNom(i);
  end;
end;

{Ahora si a programar las funciones para cálculo de probabilidades para nuevos
ejemplos. Que claro, vienen del conjunto P.
La más sencilla primero o quizá se me complique por accesos al arreglo qwq

}

function TForm3.probNominal(col, clase,x: integer): real;
begin
  //writeln(matrizFrecuenciasG[col, clase, x], ' / ', contaFG[clase]);
  probNominal:= (matrizFrecuenciasG[col, clase, x] / contaFG[clase]);
end;

function TForm3.calcularDensidad(x, media, desvE: real): real;
var
  px: real;
begin
  {writeln(desvE * sqrt(2*Pi));
  writeln(power(x - media, 2));
  writeln(2 * power(desvE, 2));
  writeln(exp(-(power(x - media, 2)/(2 * power(desvE, 2)))));}
  px:= (1 / (desvE * sqrt(2*Pi))) * exp(-(power(x - media, 2)/(2 * power(desvE, 2))));
  calcularDensidad:= px;
end;

function TForm3.predictDecF(x: array of string): integer;
var
  pnva, pac, pMayor: real;
  pertenecea: integer;
  i, j: integer;
begin
  pMayor:=-1;
  pertenecea:=-1;
  for i:=0 to noClases-1 do begin
    pac:=1;
       for j:=0 to length(headers)-1 do begin
         pnva:=0;
           if headers[j] <> 0 then begin
              pnva:= probNominal(j,i,strtoint(x[j]));

              write('Columna: ', j,' Categorias: ', headers[j]);
              writeln(' Categoria: ', strtoint(x[j]), ' Probabilidad nueva: ', pnva);
              writeln('PAC: ', pac);
              if pnva <= 0 then begin
                pnva := 1E-100;
              end;
              pac:= pac * pnva;
              //pac:= pac + ln( pnva);
              writeln('Probabilidad acumulada: ', pac);

           end
           else begin
               pnva:=calcularDensidad(strtofloat(x[j]), matrizMedias[j,i], matrizDesviacionesE[j,i]);

               write('Columna: ', j, ' x: ', strtofloat(x[j]));
               writeln('Media: ', matrizMedias[j,i], ' Desviacion E: ',matrizDesviacionesE[j,i]);
               writeln(' Probabilidad nueva: ', pnva);
               writeln('PAC: ', pac);
               {PARECE QUE PASCAL NO NOS DEJARÁ MULTIPLICAR A GUSTO LOS FLOTANTES qwq}
               if pnva <= 0 then
               begin
                    pnva := 1E-100;
               end;
               //pac:= pac * pnva;
               pac:= pac + ln(pnva);
               writeln('Probabilidad acumulada: ', pac);
           end;

       end;
       pac:= pac + ln(probaprXclase[i]);
       WriteLn();
       WriteLn(' Apriori: ', probaprXclase[i], ' Probabilidad de pertenecer a la clase ', i, ' =', pac);
       WriteLn();
       if i=0 then begin
          pMayor:=pac;
          perteneceA:=i;
       end;

       if pac > pMayor then begin
          pMayor:=pac;
          perteneceA:=i;
       end;
  end;
  WriteLn('Probabilidad final: ',  pMayor, ' Clase: ', perteneceA);
  predictDecF:= perteneceA;
end;






procedure TForm3.Label2Click(Sender: TObject);
begin
  //idea podriamos poner colores de semaforo de acuerdo al nivel de exactidud
end;

procedure TForm3.Label3Click(Sender: TObject);
begin

end;

procedure TForm3.Button5Click(Sender: TObject);
begin

end;

procedure TForm3.Button4Click(Sender: TObject);
begin

end;

{--------------Conjunto de entrenamiento de Naive Bayes--------------}
procedure TForm3.Button1Click(Sender: TObject);
var
  j: real;
begin
  if OpenDialog1.Execute then begin
      StringGrid1.LoadFromCSVFile(OpenDialog1.FileName);
      {Inicialización de tamaños para las distintas matrices.}
      cargarDatosLimpios(stringgrid1.RowCount-1, stringgrid1.ColCount-1);
      setlength(matrizMedias, length(headers), noClases);
      setlength(matrizDesviacionesE, length(headers), noClases);
      setlength(matrizFrecuenciasG, length(dataSetLimpio[0]));
      naiveBayesEntrenamientoT();
      j:= predictDecF(['-2.946', '1.649', '0', '0', '-1.167', '0.788', '-0.909', '1.3', '-0.562', '0.902', '-0.07', '-0.842', '1', '0', '1']);
  end;

end;

procedure TForm3.PageControl1Change(Sender: TObject);
begin

end;

end.

