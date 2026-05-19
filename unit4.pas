unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Buttons, StdCtrls, Grids, Spin, ColorBox, Menus, TAGraph, TASeries, Math;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button7: TButton;
    Chart1: TChart;
    Chart1BarSeries1: TBarSeries;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    RadioGroup1: TRadioGroup;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

    procedure Button7Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure StringGrid2Click(Sender: TObject);
    procedure TabSheet2Show(Sender: TObject);

  private
    procedure cargarDatosLimpios(fils, cols: integer);
    procedure calcularProbabilidadesApr();
    procedure probabilidadesAtributoNum(columna: integer);
    procedure probabilidadesAtributoNom(columna: integer);
    procedure naiveBayesEntrenamientoT();
    procedure testingP();

    function calcularDensidad(x, media, desvE: real): real;
    function probNominal(col, clase, x: integer): real;
    {para esta usamos extrañamente un array of string porque no sé que vaya a
    caer, si integer o real, mejro convertirlos}
    function predictDecF(x: array of string): integer;

    procedure cargarDatosP(fils, cols: integer);

    procedure kfoldc(nFolds: integer);
    procedure newDSwithFolds(noFolds,leavOUT: integer; folks: array of TStringList);
    function pruebasAEntrenamientos(pruebaF: integer; folks: array of TStringList): real;
    procedure recovery(fils, cols: integer);

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
  backup: array of array of real;
  dataSetP: array of array of real;
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
  verosimilitudesGraph: array of real;
  {matrizFrecuencias: array of array of integer;}
  matrizFrecuenciasG: array of array of array of integer;
  {NAIVE BAYES, ENTRENAMIENTO CON EL CONJUNTO T}
  F:Textfile;
  F2:Textfile;
  colores: array of TColor;
  lineas:TStringList;
implementation

uses
    Unit3;
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
  writeln(fils, ' ', cols);
  SetLength(dataSetLimpio, fils, cols);
  SetLength(backup, fils, cols);
  SetLength(headers, cols);
  SetLength(lastColumn, fils);




  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSetLimpio[i,j]:= StrToFloat(StringGrid1.Cells[j,i+1]);
      backup[i,j]:= dataSetLimpio[i,j];
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

procedure TForm3.recovery(fils, cols: integer);
var
  i,j: integer;
begin
  writeln(fils, ' ', cols);
  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSetLimpio[i,j]:= backup[i,j];
    end;
  end;
  naiveBayesEntrenamientoT();
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
  setlength(verosimilitudesGraph, noClases);
  pMayor:=-1;
  pertenecea:=-1;
  for i:=0 to noClases-1 do begin
    pac:=1;
       for j:=0 to length(headers)-1 do begin
         pnva:=0;
           if headers[j] <> 0 then begin
              pnva:= probNominal(j,i,strtoint(x[j]));
              {
              writeLN('Clase: ', i);
              write('Columna: ', j,' Categorias: ', headers[j]);
              writeln('Prob anterior: ', pac);
              writeln('Categoria: ', strtoint(x[j]), ' Probabilidad nueva: ', pnva);
              }

              if pnva <= 0 then begin
                pnva := 1E-100;
              end;
              pac:= pac * pnva;
              //pac:= pac + ln( pnva);
              {
              writeln('Probabilidad acumulada: ', pac);
              }
           end
           else begin
               pnva:=calcularDensidad(strtofloat(x[j]), matrizMedias[j,i], matrizDesviacionesE[j,i]);

               {
               writeLN('Clase: ', i);
               write('Columna: ', j, ' x: ', strtofloat(x[j]));
               writeln('Media: ', matrizMedias[j,i], ' Desviacion E: ',matrizDesviacionesE[j,i]);
               writeln(' Probabilidad nueva: ', pnva);
               writeln('Prob anterior: ', pac);
               }
               {PARECE QUE PASCAL NO NOS DEJARÁ MULTIPLICAR A GUSTO LOS FLOTANTES qwq}
               if pnva <= 0 then
               begin
                    pnva := 1E-100;
               end;
               pac:= pac * pnva;
               //pac:= pac + ln(pnva);
               {
               writeln('Probabilidad acumulada: ', pac);
               }
           end;

       end;
       pac:= pac * probaprXclase[i];
       verosimilitudesGraph[i]:= pac;
       WriteLn(verosimilitudesGraph[i], ' ',i);
       {WriteLn();
       WriteLn(' Apriori: ', probaprXclase[i], ' Probabilidad de pertenecer a la clase ', i, ' =', pac);
       WriteLn();}
       if i=0 then begin
          pMayor:=pac;
          perteneceA:=i;
       end;

       if pac > pMayor then begin
          pMayor:=pac;
          perteneceA:=i;
       end;


  end;
  {WriteLn('Probabilidad final: ',  pMayor, ' Clase: ', perteneceA);}
  predictDecF:= perteneceA;
end;
{PROCEDIMIENTOS NECESARIOS PARA HACER LA EVALUACIÓN CON UN CONJUNTO P}
procedure TForm3.testingP();
var
  i,j: integer;
  entrada: array of string;
  countPos: integer;
  countNeg: integer;
  r: string;
  precision: real;

  begin
  entrada:=nil;
  setlength(entrada, length(headers));

  countPos:=0;
  countNeg:=0;

  for i:=0 to length(dataSetP)-1 do begin

      for j:=0 to length(dataSetP[0])-1 do begin
          entrada[j]:= stringgrid2.Cells[j,i];
          //entrada[j]:= floattostr(dataSetLimpio[i,j]);
      end;
      {
      write('Linea en evaluacion: ');
      for j:=0 to length(dataSetP[0])-1 do begin
        write(entrada[j]);
        write(' ');
      end;

      }
      r:=stringgrid2.Cells[length(dataSetP[0]),i];

      writeln();
      writeln('Clase real: ', r);

      j:= predictDecF(entrada);
      if j = strtoint(r) then
         inc(COUNTPOS);
      if j <> strtoint(r) then
         inc(COUNTneg);
      writeln('Prediccion: ',j);
  end;
 //writeln('Incorrectos: ', countneg,' Error: ', FormatFloat('0.000000', COUNTneg/length(dataSetP)));
 //writeln('Correctos: ', countpos,' Accuracy: ',FormatFloat('0.000000',(countPos/length(dataSetP))*100));
 precision:= (countpos/length(dataSetP)*100);

 Label6.Caption:='Precisión: ';
 Label6.Caption:=Label6.Caption  + FormatFloat('0.00',precision) + '%';


 Label8.Caption:='Error: ';
 Label8.Caption:=Label8.Caption  + FormatFloat('0.00',(COUNTneg/length(dataSetP)));

end;

procedure TForm3.cargarDatosP(fils, cols: integer);
var
  i,j: integer;
begin

  SetLength(dataSetP, fils, cols);

  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSetP[i,j]:= StrToFloat(StringGrid2.Cells[j,i+1]);
    end;
  end;
  stringgrid2.DeleteRow(0);

  {for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      writeln(dataSetP[i,j]);
    end;
    writeln();
  end;        }
end;


{K FOOOOLS}
procedure TForm3.kfoldc(nFolds: integer);
var
  clasificacion:array of TStringList;
  folks: array of TStringList;
  i,j, ran, foldActual: integer;
  linea, aux: string;
  precision, preRound: real;
begin
  clasificacion:=nil;
  folks:=nil;

  setlength(clasificacion, noClases);
  setlength(folks, nFolds);

  for i:=0 to noClases-1 do begin
    clasificacion[i]:= TStringList.Create;
  end;

  for i:=0 to length(lastColumn)-1 do begin
    linea:='';
    for j:=0 to length(dataSetLimpio[0])-1 do begin
      linea:= linea +floattostr(dataSetLimpio[i,j]);
      if j < length(dataSetLimpio[0]) then
        linea:=linea + ',';
    end;
    linea:=linea + floattostr(lastColumn[i]);
    clasificacion[lastColumn[i]].Add(linea);
  end;

  randomize();
  {para revolver los datos de forma aleatoria se hará desde la última
  posición hasta la 0}
  for i:=0 to noClases-1 do begin
    if clasificacion[i].Count > 1 then begin
       for j:=clasificacion[i].Count-1 downto 0 do begin
             ran:= random(j+1);
             aux:=clasificacion[i].Strings[j];
             clasificacion[i].Strings[j]:= clasificacion[i].Strings[ran];
             clasificacion[i].Strings[ran]:= aux;
       end;
    end;
  end;


  for i:=0 to nFolds-1 do begin
    folks[i] := TStringList.Create;
  end;

  {
  Al parecer al hacer los folds se quiere asegurar que cada fold tenga una parte
  de cada clase y que justamente sea estratificado, como en cartas cawn
  }

  for i:=0 to noClases-1 do begin
    {Iniciamos a repartir los folds desde 0 o primer fold qwq\
    se hara como en un circulo 0,...,9,0,...,}
    foldActual:=0;
    {Aqui es donde repartimos T entre los folds para que sea justo
    cuando se acaben los de esta clase ya me paso a otra, como
    si repartiera colores a la banda y todos deben tener 1 de cada uno xd
    y pues me tengo que mover de persona}

    {
    RECORDAR: clasificacion[i].Count-1 me indica el rango de localidades de memoria
    disponibles por cada una de las clasificaciones que se hicieron
    porque count sin -1 es la cantidad real por clase.
    }

    for j:=0 to clasificacion[i].Count-1 do begin
      //writeln(clasificacion[i].Count-1);
      //writeln(foldActual);
      //writeln(clasificacion[i].Strings[j]);
      folks[foldActual].Add(clasificacion[i].Strings[j]);

      foldActual:=foldActual+ 1;

      if foldActual > nFolds-1 then
        foldActual:= 0;
      {pa evitar que mi foldactual ocasione un overflow reiniciamos contador}
    end;

  end;
  {no more trash on ram viejo}
  for i := 0 to noClases-1 do begin
    clasificacion[i].Free;
  end;

  precision:= 0;

  for foldActual:=0 to nFolds-1 do begin
      newDSwithFolds(nFolds,foldActual, folks);
      naiveBayesEntrenamientoT();

      preround := pruebasAEntrenamientos(foldActual, folks);
      precision := precision + preround;

      {para ir viendo como cambian los valores de fold actual
      y cuales van a ser los numeros que se van a sumar
      WriteLn('Ronda ', foldActual + 1, ': ', preRound:0:6, '%');}
  end;
  precision:= precision/nFolds;
  Label2.Caption:=' Desempeño: ';
  Label2.Caption:=Label2.Caption  + FormatFloat('0.00',precision) + '%';

end;

procedure TForm3.newDSwithFolds(noFolds,leavOUT: integer; folks: array of TStringList);
var
  i,j, k, pos: integer;
  line: TStringlist;
begin

  line:= nil;
  line := TStringList.Create;
  line.StrictDelimiter := True;
  line.Delimiter := ',';
  pos:=0;

  for i:=0 to noFolds-1 do begin


    if i = leavOUT then begin {ahora ignoramos a un foldjaja}
       continue;
    end;

    for j:=0 to folks[i].count-1 do begin
        {
        folks[i].count cuantas lineas per group
        folks[i].Strings[j] cada una de las lineas per group
        }
        line.DelimitedText:=folks[i].Strings[j];
        pos:=0;

        for k:=0 to length(dataSetLimpio[0])-1 do begin

            dataSetLimpio[pos, k]:= strtofloat(line.Strings[k]);
            //writeln(dataSetLimpio[pos, k]);

        end;
        inc(pos);
        {
        writeln('DEBUG NO ESTA PASANDO LA ULTIMA COL A DATASETLIMPIO C:');
        }



    end;
  end;
  line.Free;
end;

function TForm3.pruebasAEntrenamientos(pruebaF: integer; folks: array of TStringList): real;
var
  i,j: integer;
  entrada: array of string;
  countPos: integer;
  countNeg: integer;
  clase: integer;
  linesfromF:TStringList;
  salida: integer;
  r: string;

begin
  entrada:=nil;
  setlength(entrada, length(headers));
  countPos:=0;
  countNeg:=0;
  linesfromF:= TStringList.Create;
  linesfromF.StrictDelimiter := True;
  linesfromF.Delimiter := ',';

  for i:=0 to folks[pruebaF].Count-1 do begin
      linesfromF.DelimitedText := folks[pruebaF].Strings[i];

      for j:=0 to length(dataSetLimpio[0])-1 do begin
        entrada[j]:= linesFromF.strings[j];
      end;

      clase:= strtoint(linesfromF.Strings[length(dataSetLimpio[0])]);
      salida:= predictDecF(entrada);

      if salida = clase then begin
         countPos:= countPos+1;
      end
      else
          countNeg:=countNeg+1;
  end;
  linesFromF.Free;
  pruebasAEntrenamientos:= (countPos / folks[pruebaF].Count) * 100;

end;

procedure TForm3.Label2Click(Sender: TObject);
begin
  //idea podriamos poner colores de semaforo de acuerdo al nivel de exactidud
end;

procedure TForm3.Label3Click(Sender: TObject);
begin

end;



{EVALUAR P}
procedure TForm3.Button7Click(Sender: TObject);
begin
  testingP();
end;

procedure TForm3.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Form2.Show;
end;




{--------------Conjunto de entrenamiento de Naive Bayes--------------}
procedure TForm3.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
      StringGrid1.LoadFromCSVFile(OpenDialog1.FileName);
      {Inicialización de tamaños para las distintas matrices.}
      cargarDatosLimpios(stringgrid1.RowCount-1, stringgrid1.ColCount-1);
      setlength(matrizMedias, length(headers), noClases);
      setlength(matrizDesviacionesE, length(headers), noClases);
      setlength(matrizFrecuenciasG, length(dataSetLimpio[0]));
      naiveBayesEntrenamientoT();
      //entrada:= ['-3.665', '0.337', '0', '0', '-0.641', '1.791', '-0.194', '1.686', '-0.359', '0.57', '-0.676', '-0.841', '2', '1', '0'];
      //j:= predictDecF(entrada);
      //writeln(j);
      //testingPCT();
  end;

end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
      StringGrid2.LoadFromCSVFile(OpenDialog1.FileName);
      cargarDatosP(stringgrid2.RowCount-1, stringgrid2.ColCount-1);
  end;
end;

procedure TForm3.Button3Click(Sender: TObject);
begin

   if spinedit1.Value <> -1 then begin
      kfoldc(spinedit1.value);

   end;

end;

procedure TForm3.PageControl1Change(Sender: TObject);
begin

end;

procedure TForm3.SpinEdit1Change(Sender: TObject);
begin
  recovery(stringgrid1.RowCount, stringgrid1.ColCount-1);
end;

procedure TForm3.StringGrid2Click(Sender: TObject);
var
   filaSelec, col: integer;
   entrada: array of string;
   predict: integer;
begin
  entrada:=nil;
  setlength(entrada,length(dataSetP[0]));
  filaSelec := StringGrid2.Row;

  for col:=0 to length(dataSetP[0])-1 do begin
    entrada[col]:= StringGrid2.Cells[col, filaSelec];
  end;

  predict:= predictDecF(entrada);

  Chart1BarSeries1.Clear;
  //reutilizamos col porque pues lo voy a limpiar a 0
  for col:=0 to noClases-1 do begin
    if col= predict then
      Chart1BarSeries1.AddXY(col, verosimilitudesGraph[col], 'C' + IntToStr(col), clGreen)
    else
      Chart1BarSeries1.AddXY(col, verosimilitudesGraph[col], 'C' + IntToStr(col), clRed);
  end;
end;

procedure TForm3.TabSheet2Show(Sender: TObject);
begin
  Image1.Canvas.Brush.Color:=clWhite;
  Image1.Canvas.Rectangle(0,0,Image1.Width,Image1.Height);
end;

{
TRATARE DE QUE TODO LO DE LOS DATOS SINTETICOS QUEDEN AQUI AUNQUE ME CUESTE ANDAR
BUSCANDO POR TODO EL CODIGO
}
{clickeo para que se pinten las n clases que dijo el usuario}
{
También la modificacion de alguna clase selecta, color y figura
igual es un poco irrelevante porque sera de la misma clase pero pues visualmente
es interesante
No pude }
procedure TForm3.Button4Click(Sender: TObject);
var
  i:integer;
begin
  setlength(colores, 7);
  lineas:=TStringList.Create;
  colores[0]:=clRed;
  colores[1]:=clNavy;
  colores[2]:=clLime;
  colores[3]:=clYellow;
  colores[4]:=clBlue;
  colores[5]:=clFuchsia;
  colores[6]:=clAqua;

  radiogroup1.Items.Clear;
  for i:=0 to spinedit2.Value-1 do begin
      radiogroup1.Items.Add('Clase: ' + inttostr(i));
  end;
end;

procedure TForm3.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  linea: string;

begin


  if Button=mbLeft then
  begin
     if radioGroup1.ItemIndex < 7 then begin
        image1.Canvas.Brush.Color:=colores[radioGroup1.ItemIndex];
        Image1.Canvas.Ellipse(X-4,Y-4,X+4,y+4);

     end
     else begin
         image1.Canvas.Brush.Color:=colores[radioGroup1.ItemIndex mod 7];
         Image1.Canvas.Ellipse(X-4,Y-4,X+4,y+4);
     end;
     linea:= floattostr(X/100) + ',' + floattostr(Y/100) + ',' + IntToStr(radioGroup1.ItemIndex);
     lineas.Add(linea);
  end;

end;
procedure TForm3.Button5Click(Sender: TObject);
var
  hdrs: string;
  i:integer;
begin
  if lineas.Count= 0 then begin
       ShowMessage('Nada que guardar');
       Exit;
  end;
  if savedialog2.Execute then begin
     AssignFile(F2,Savedialog2.FileName);

     {$I-}
         rewrite(F2);  //crear archivo...si existe Sobre escribe y destruye
    {$I+}


    if IOResult=0 then
    begin
     hdrs:= '0,0,' + inttostr(spinedit2.Value);
     Writeln(F2, hdrs);

      for i:=0 to lineas.Count-1 do begin
          Writeln(F2, lineas.Strings[i]);
      end;


    end;
     lineas.Clear;
     Image1.Canvas.Clear;
     Image1.Canvas.Brush.Color:=clWhite;
     Image1.Canvas.FillRect(0, 0, Image1.Width, Image1.Height);
  end;
  showMessage('Archivo guardado exitosamente.');
  closeFile(F2);
end;



end.

