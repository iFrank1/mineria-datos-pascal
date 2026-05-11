unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, Grids, StdCtrls,
  ComCtrls, RTTICtrls, TASeries, TAGraph, Math, TAChartUtils, TAMultiSeries, Unit2;

type
  matrizDatos = array of array of real;
  arrayDatos = array of real;
  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Chart1: TChart;
    Chart1BarSeries1: TBarSeries;
    Chart1BoxAndWhiskerSeries1: TBoxAndWhiskerSeries;
    Chart1LineSeries1: TLineSeries;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);

    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private


  public
    procedure cargarDatos(fils, cols: integer);


    procedure calMedXCol(fils, cols: integer);
    procedure calDesvXCol(fils, cols: integer);

    //metodos de normalizacion de datos numericos vistos en clase
    procedure sinNorm(fils, cols: integer);

    procedure normZscore(fils, cols: integer);

    procedure minMax(fils, cols: integer);
    function minimoColumna(fils, j: integer): real;
    function maximoColumna(fils, j: integer): real;
    function nuevoMin(): string;
    function nuevoMax(): string;

    procedure escDecimal(fils, cols: integer);
    function obtenerJ(maxA: real): real;
    function obtValAbsMax(fils, j: integer): real;

    //graficas
    procedure graficaBarras(fils, col, clases: integer);

    procedure listaXYparaDisp();
    procedure graficaDisper(fils, col1, col2: integer);

    procedure listaBP();
    procedure graficaBoxPlot(fils, clases, atriSelect: integer);
    procedure graficaBoxPlotGeneral(fils, cols: integer);

  end;

var
  Form1: TForm1;
  dataSet: matrizDatos;
  dataNorm: matrizDatos;
  ubCols: array of integer;
  F:Textfile;

implementation

{uses
  Unit2;}

{$R *.lfm}

{ TForm1 }

procedure TForm1.cargarDatos(fils, cols: integer);
//datos en visualización y almacenados en una matriz para operar
var
  i,j: integer;
begin

  SetLength(dataSet, fils, cols);
  SetLength(dataNorm, fils, cols);

  //showmessage(inttostr(StringGrid1.RowCount)+ ' ' +  inttostr(StringGrid1.ColCount));
  //primero cargo todos los datos por si necesito las cabeceras y las clases
//que seguramente m[as adelante
  for i:=0 to fils-1 do begin
    for j:=0 to cols-1 do begin
      dataSet[i,j]:= StrToFloat(StringGrid1.Cells[j,i]);
      dataNorm[i,j]:=dataSet[i,j];
    end;
  end;
  //showmessage(floattostr(dataSet[0,cols-1]));

  //luego en un nuevo string grid que probablemente sea el 1 de nuevo?
  //lo dimensiono quitando la primera fila y la ultima columna porque
  //ahora mismo no quiero qu ese muestren
  StringGrid1.RowCount:=fils-1;
  StringGrid1.ColCount:= cols-1;

  //showmessage(inttostr(StringGrid1.RowCount)+ ' ' +  inttostr(StringGrid1.ColCount));
  //showmessage(inttostr(fils)+ ' ' +  inttostr(cols));
  //cargo los datos en mi nuevo grid ya sin la cabecera y ultima columna
  for i:=0 to stringgrid1.RowCount-1 do begin
    for j:=0 to stringgrid1.ColCount-1 do begin
      StringGrid1.Cells[j,i]:= FloatToStr(dataSet[i+1,j]);
    end;
  end;


  {
  pruebas con un grid aparte en el que iba viendo que no me saltara datos
  StringGrid2.RowCount:=fils-1;
  StringGrid2.ColCount:= cols-1;

  //cargo los datos en mi nuevo grid ya sin la cabecera y ultima columna
  for i:=0 to stringgrid2.RowCount-1 do begin
    for j:=0 to stringgrid2.ColCount-1 do begin
      StringGrid2.Cells[j,i]:= FloatToStr(dataSet[i+1,j]);
    end;
  end;

  }

end;

//calculo de la media + desviacion


//calculo de la media por columna
procedure TForm1.calMedXCol(fils, cols: integer);
var
  i,j: integer;
  sum: real;

begin
  //ajustar al stringgrid para que concuerde a todas las columnas
  StringGrid2.ColCount:= cols;

  for j:=0 to cols-1 do begin
    sum:= 0;
    //cuando el encabezado indique que no es numerico simplemente saltamos esa
      //columna, no le calculamos la media (se tendran 0s)
      if dataNorm[0,j] <> 0 then begin
        continue;
      end;

    for i:=0 to fils-1 do begin

      //se reinician por columna a 0, cada uno tiene media y desv aparte
      sum:= sum + dataNorm[i+1,j];
    end;
    //luego de recorrer una columna y tener la sumatoria, obtengo la media
    stringgrid2.Cells[j,0]:= FloatToStr(sum/Real(fils));
  end;

end;

//calculo de la desviacion estandar por columna
procedure TForm1.calDesvXCol(fils, cols: integer);
var
  i,j: integer;
  sumC, mediaCol: real;

begin
  //ajustar al stringgrid para que concuerde a todas las columnas
  StringGrid2.ColCount:= cols;

  for j:=0 to cols-1 do begin
    sumC:= 0;
    //cuando el encabezado indique que no es numerico simplemente saltamos esa
      //columna, no le calculamos la media (se tendran 0s)
    if dataNorm[0,j] <> 0 then begin
      continue;
    end;
    mediaCol := StrToFloat(StringGrid2.Cells[j, 0]);
    for i:=0 to fils-1 do begin

      //se reinician por columna a 0, cada uno tiene media y desv aparte
      sumC:= sumC + power((dataNorm[i+1,j] - mediaCol), 2);
    end;
    //luego de recorrer una columna y tener la sumatoria, obtengo la desvEst
    stringgrid2.Cells[j,1]:= FloatToStr(sqrt(sumC/Real(fils)));
  end;
end;


//Sin normalizar
procedure TForm1.sinNorm(fils, cols: integer);
var
  i,j: integer;
begin


  for j:=0 to cols-1 do begin
      for i:=0 to fils-1 do begin
          stringgrid1.cells[j,i]:= floattostr(dataSet[i+1,j]);
      end;
  end;
  for i:=0 to fils-1 do begin
      for j:=0 to cols-1 do begin
          dataNorm[i,j]:= dataSet[i,j];
      end;
  end;


end;



//normalizacion Z-Score

//EL DIABLO, PARECE QUE ZSCORE ME QUIERE OBLIGAR A RECALCULAR SUS MEDIAS Y
//DESVIACIONES SIN REUTILIZAR FUNCIONESS WTF
procedure TForm1.normZscore(fils, cols: integer);
var
  i,j: integer;
  norm, sum, sumC, mediaCol, desvCol: real;
begin


  for j:=0 to cols-1 do begin
  //seguimos saltando no numericos
    if dataSet[0,j] <> 0 then begin
      continue;
    end;
    sum:=0;

    for i:=0 to fils-1 do begin
      sum:= sum+ dataSet[i+1,j];
    end;
    mediaCol:=sum/Real(fils);

    sumC:=0;
    for i:=0 to fils-1 do begin
        sumC:=sumC+Power(dataSet[i+1,j]-mediaCol, 2);
    end;
    desvCol:=sqrt(sumC/Real(fils));


    for i:=0 to fils-1 do begin
      //z score
      norm := (dataSet[i+1,j] - mediaCol)/desvCol;
      stringgrid1.Cells[j,i]:= FloatToStr(norm);
      dataNorm[i+1,j]:= norm;

    end;
    {
    StringGrid2.Cells[j, 0] := '0.0000';
    StringGrid2.Cells[j, 1] := '1.0000';
    }
    end;
end;

//normalizacion min max y sus funciones necesarias para lograrlo
function TForm1.minimoColumna(fils, j: integer): real;
var
  i, b: integer;
  min: real;

begin
     b:=0;

       for i:=0 to fils-1 do begin

           if (b = 0) then begin
              min:= dataSet[i+1,j];
              b:= 1;
           end;
           if (dataSet[i+1,j] < min) then begin
              min:= dataSet[i+1,j];
           end;
       end;
     minimoColumna:= min;
     //showMessage(floattostr(min));
end;

function TForm1.maximoColumna(fils, j: integer): real;
var
  i, b: integer;
  max: real;

begin
     b:= 0;

       for i:=0 to fils-1 do begin

           if (b = 0) then begin
              max:= dataSet[i+1,j];
              b:= 1;
           end;

           if (dataSet[i+1,j] > max) then begin
              max:= dataSet[i+1,j];
           end;
       end;
     maximoColumna := max;
     //showMessage(floattostr(max));
end;

function TForm1.nuevoMin(): string;
begin

     nuevoMin:=inputBox('Configuración Min-Max', 'Nuevo mínimo:', '0');
end;

function TForm1.nuevoMax(): string;
begin
     nuevoMax:= inputBox('Configuración Min-Max', 'Nuevo máximo:', '1');

end;

procedure TForm1.minMax(fils, cols: integer);
var
   i,j: integer;
   norm, minA, maxA, newMax, newMin, v: real;

begin

     newMax:= StrToFloat(nuevoMax());
     newMin:= StrToFloat(nuevoMin());

     for j:=0 to cols-1 do begin

         //saltar no numericos
         if dataSet[0,j] <> 0 then begin
            continue;
         end;
         maxA:= maximoColumna(fils, j);
         minA:= minimoColumna(fils, j);
         for i:=0 to fils-1 do begin



         //min max
               v:= dataSet[i+1,j];
         //showMessage(floattostr(v));
              norm := (((v - minA) / (maxA - minA))*(newMax - newMin)) + newMin;
              stringgrid1.Cells[j,i]:= FloatToStr(norm);
              dataNorm[i+1,j]:= norm;
         end;

     end;

end;

//normalizacion escalado decimal y sus funciones necesarias para lograrlo

function TForm1.obtValAbsMax(fils, j: integer): real;
var
  i, b: integer;
  max: real;

begin
     b:= 0;

       for i:=0 to fils-1 do begin

           if (b = 0) then begin
              max:= abs(dataSet[i+1,j]);
              b:= 1;
           end;

           if (abs(dataSet[i+1,j]) > max) then begin
              max:= abs(dataSet[i+1,j]);
           end;
       end;

     obtValAbsMax := max;
     //showMessage(floattostr(max));
end;

function TForm1.obtenerJ(maxA: real): real;
var
   j, aux: real;
begin
     //j  entero mas pequeño tal que maxAbs de v' sea < 1
     aux:= maxA;
     j:= 0;
     //divido al max hasta que sea < 1 con el 10^j correspondiente
     while maxA > 1 do begin
           j:= j + 1;
           maxA:= aux;
           maxA:= maxA / power(10.0, j);

     end;
     obtenerJ:= j;
end;

procedure TForm1.escDecimal(fils, cols: integer);
var
   i, k: integer;
   norm, maxA, j, v: real;
begin
     for k:=0 to cols-1 do begin


       //saltar no numericos
       if dataSet[0,k] <> 0 then begin
         continue;
       end;

       maxA:= obtValAbsMax(fils, k);
       //showMessage(floatToStr(obtenerJ(maxA)));
       j:= obtenerJ(maxA);

       for i:=0 to fils-1 do begin


         //escalado decimal
         v:= dataSet[i+1,k];
         //showMessage(floattostr(v));
         norm := v / power(10.0, j);
         stringgrid1.Cells[k,i]:= FloatToStr(norm);
         dataNorm[i+1,k]:= norm;
       end;
     end;

end;

procedure TForm1.graficaBarras(fils, col, clases: integer);
var
   i, r, g, b, otros: integer;
   colF: real;
   //countUnkn: integer;

   contadores: array of integer;
begin
     contadores := nil;//solo para quitar la advertencia de abajo
     //showmessage(inttostr(fils) + ' ' + inttostr(cols)+' '+inttostr(clases));
     setLength(contadores, clases);
     otros:= 0;
     for i:=0 to clases-1 do begin
         contadores[i]:= 0;
     end;

     //salto la primera fila porque no es relevante para este paso
     for i:=1 to fils-1 do begin
         //showmessage(inttostr(round(dataNorm[i, cols-1])));

         //showmessage('Hola no ando contando porque si tengo un 2 kbronazo! '
         //+ inttostr(length(contadores)));
         //error: no debemos modificar el tam cada que cuenta,
       //sino cada vez que es un numero diferente
       //showmessage(inttostr(length(dataNorm)) + ' ' +inttostr(length(dataNorm[0])) + ' ' + inttostr(fils));
       if not (round(dataNorm[i, col]) in [0..(length(contadores)-1)]) then begin
          //showmessage('Holap, hay ruido! ' + inttostr(round(dataNorm[i, col])));
          otros:= otros + 1;
          continue;
       end;
         contadores[round(dataNorm[i, col])]:= contadores[round(dataNorm[i, col])] + 1;
         //showmessage(inttostr(round(dataNorm[i, col])));
     end;

     //graficando
     //rgb propuesto para que cada una de las clases en teoria tenga un unico
     //color
     chart1barseries1.Active:=true;
     chart1barseries1.Clear;

     Chart1.BottomAxis.Marks.Style := smsLabel;
     Chart1.BottomAxis.Marks.Source := Chart1BarSeries1.Source;
     Chart1.BottomAxis.Title.Visible := False;
     Chart1.LeftAxis.Title.Visible := False;

     colF:= (5 * 3.1416 / 3) / (clases-1);
     for i:=0 to clases-1 do begin
         r:= Round(Sin(colF * i + (3.1416 / 2)) * 127 + 128);
         g := Round(Sin(colF * i + (3.1416 / 2) - (2.0 * 3.1416 / 3.0)) * 127 + 128);
         b := Round(Sin(colF * i + (3.1416 / 2) - (4.0 * 3.1416 / 3.0)) * 127 + 128);
         Chart1BarSeries1.Add(contadores[i], 'Clase: ' + inttostr(i), RGBToColor(r, g, b));
         //showmessage('Hola!');
     end;

     if otros > 0 then begin
        r:=0;
        g:=0;
        b:=0;
        Chart1BarSeries1.Add(otros, 'Otros: ?', RGBToColor(r, g, b));
     end;
end;


procedure TForm1.listaXYparaDisp();
var
   k, index, j: integer;
begin
       ubcols := nil;
       setlength(ubcols, 0);
       index:=-1;

       combobox2.Items.Clear;
       combobox3.Items.Clear;
       k:=0;
       //agregar valores para x/y
       for j:=0 to stringgrid1.ColCount do begin
           index:=index + 1;
           //volvemos a saltar no numericos
           if dataNorm[0,j] <> 0 then begin
              continue;
           end;
           setlength(ubCols, k + 1);
           ubCols[k]:=index;
           k:=k+1;
           combobox2.items.add('Atributo X: ' + inttostr(k));
           combobox3.items.add('Atributo Y: ' + inttostr(k));
       end;
       combobox2.Visible:=True;
       combobox3.Visible:=True;
       button1.Visible:=True;



end;

procedure TForm1.listaBP();
var
   k, index, j: integer;
begin
  ubcols := nil;
  setlength(ubcols, 0);
  index:=-1;

  combobox4.Items.Clear;

  k:=0;

  for j:=0 to stringgrid1.ColCount do begin
      index:=index + 1;
      //volvemos a saltar no numericos
      if dataNorm[0,j] <> 0 then begin
         continue;
      end;
      setlength(ubCols, k + 1);
      ubCols[k]:=index;
      k:=k+1;
      combobox4.items.add('Atributo: ' + inttostr(k));

  end;
  combobox4.Visible:=True;
  //button1.Visible:=True;
end;

procedure TForm1.graficaDisper(fils, col1, col2: integer);
var
   i,x,y: integer;
begin
     x:= ubCols[col1];
     y:= ubCOls[col2];

     //showmessage(inttostr(x) + ' ' + inttostr(y));

     Chart1.BottomAxis.Marks.Source := nil;

     Chart1.BottomAxis.Marks.Style := smsValue;
     Chart1.BottomAxis.Title.Visible := True;
     Chart1.BottomAxis.Title.Caption := ComboBox2.Text;

     Chart1.LeftAxis.Marks.Style := smsValue;
     Chart1.LeftAxis.Title.Visible := True;
     Chart1.LeftAxis.Title.Caption := ComboBox3.Text;

     for i := 1 to fils-1 do begin
         Chart1LineSeries1.AddXY(dataNorm[i, x], dataNorm[i, y]);
    end;

end;

procedure TForm1.graficaBoxPlot(fils, clases, atriSelect: integer);
var
   i, queClase, colRe, lc, s, ubMitad, ubMitadq1: integer;
   allBoxes: array of array of real;
   contadores: array of Integer;
   valEnFila, min, max, mediana, q1, q3: real;
begin

     allBoxes:= nil;
     contadores:= nil;

     lc:=length(dataNorm[0])-1;
     //showmessage(inttostr(lc));
     //showmessage(inttostr(atriSelect));
     colRe:= ubCols[atriSelect];
     SetLength(allBoxes, clases);
     SetLength(contadores, clases);
     //WriteLn(length(contadores), dataNorm[fils-1, 0]);
     for i:=0 to clases-1 do begin
       contadores[i]:= 0;
     end;
     //contamos cuantos valores hay de cada clase en la columna selecta
     //si son 11 primero sacamos a que clase pertenece para aprovechar que va
     //de 0 a n-1 y ahi mismo contar
     s:=0;
     for i:=1 to fils-1 do begin
       queClase:= round(dataNorm[i,lc]);
       INC(contadores[queClase]);

     end;

     {for i:= 0 to clases-1 do begin
       //WriteLn(i, ' ', contadores[i]);
       s:=s+contadores[i];
     end;}
     //WriteLn(s, ' ', stringgrid1.RowCount);
     //una vez que ya sabemos cuantos valores hay de cada clase en la columna
     //selecta ahora vamos a hacer otros arreglos donde vamos a guardar
     //los n valores flotantes de cada clase
     for i:=0 to clases-1 do begin
         setlength(allBoxes[i], contadores[i]);
       contadores[i]:=0;
     end;
     //aqui empezamos a extraer los valores flotantes de cada clase
     //poniendolos en donde les corresponde
     for i:=1 to fils-1 do begin
         queClase:= round(dataNorm[i,lc]);
         valEnFila:= dataNorm[i, colRe];

         allBoxes[queClase][contadores[queClase]]:=valEnFila;

         Inc(Contadores[queClase]);

         //los contadores[claseActual] van a empezar en 0 y no importa es
         //como si tuvieramos mucho i,j,k para cada clase. No importa tanto
         //que tanto crezca con inc porque teoricamente solo llegaria hasta
         //los n elementos de dicha clase que haya
     end;
     for i:=0 to clases-1 do begin
       for s:=0 to length(allboxes[i])-1 do begin
         writeln('clase ', i, ' ', allBoxes[i][s]);
       end;
     end;

     //ordenamos para las medianasssss y vamos graficando finalmente
     //todo a la par X_X

     for i:=0 to clases-1 do begin
       QuickSort(allboxes[i], 0, Contadores[i] - 1);
       min:= allboxes[i][0];
       max:= allboxes[i][contadores[i]-1];

       ubMitad:= (contadores[i]-1) div 2;

       //calculo de la mediana
       if (contadores[i]) mod 2 = 0 then begin
          mediana:=  (allboxes[i][ubMitad] + allboxes[i][ubMitad+1]) / 2.0;
       end
       else begin
         mediana:=  allboxes[i][ubMitad];

       end;

       //se calcula q1, media de la mitad izq
       ubMitadq1:= ((contadores[i] div 2) - 1) div 2;

       if (contadores[i] div 2) mod 2 = 0 then begin
          q1:= (allboxes[i][ubMitadq1] + allboxes[i][ubMitadq1 + 1]) / 2.0;
       end
       else begin
         q1:= allboxes[i][ubMitadq1];
       end;


       {
       DEBUGGGG, IGNORARRRR
       para sacar q3 habra que hacer una suma,
       basicamente es la ubicacion de la mitad de los datos + la mitad de la
       mitad lo que en teoria va dando el 75
       si la cantidad de elementos es impar se hace un promedio entonces hay
       una media con ubicacion real y pues misma cantidad de elementos de un
       lado que del otro
       cu... lo termino en libreta}
      s:= contadores[i] - (contadores[i] div 2);

       if (contadores[i] div 2) mod 2 = 0 then begin
          q3:= (allboxes[i][s + ubMitadq1] + allboxes[i][s + ubMitadq1 + 1]) / 2.0;
       end
       else begin
         q3:= allboxes[i][s + ubMitadq1];

       end;

       
       {
       DEBUGGGG, IGNORARRRR
       for s:=0 to length(allboxes[i])-1 do begin
         writeln(s, 'clase ', i, ' ', allBoxes[i][s]);
       end;

       //parece qeu se puedenn truncar valroes reales, aqui se hace a modo
       //de visualizaicon nada mas min:0:2

       writeln();
       writeln(' ', (contadores[i]) mod 2, ' min:', min:0:2, ' q1: ', q1:0:2, ' mediana: ', mediana:0:2, ' q3: ', q3:0:2, ' max: ', max:0:2);
       writeln('elementos de la clase ', contadores[i], ' Mitad ', ubMitad,' ', contadores[i]-1, ' ', allboxes[i][ubMitad]);
       }

       //FINALMENTE GRAFICO, FAK VIEJON
       Chart1.BottomAxis.Marks.Source := nil;
       Chart1.BottomAxis.Title.Visible := True;
       Chart1.BottomAxis.Title.Caption := 'Clases';
       Chart1.BottomAxis.Marks.Style := smsValue;


       Chart1.LeftAxis.Title.Visible := True;
       Chart1.LeftAxis.Title.Caption := 'Valor';

       Chart1BoxAndWhiskerSeries1.AddXY(i, min, q1, mediana, q3, max, IntToStr(i));

     end;


end;

procedure TForm1.graficaBoxPlotGeneral(fils, cols: integer);
var
   i, j, s, n, ubMitad, ubMitadq1: integer;
   ArregloGlobal: array of real;
   min, max, mediana, q1, q3: real;
begin
     ArregloGlobal:= nil;
     setlength(ArregloGlobal, fils);

     for i:=0 to cols-1 do begin
       n:= 0;
       if dataNorm[0,i] <> 0 then begin
           continue;
       end;
       for j:=1 to fils-1 do begin
           //showmessage(inttostr(n));

           arregloGlobal[n]:= dataNorm[j,i];
           n := n + 1;
       end;

       QuickSort(arregloGlobal, 0, n-1);
       min:= arregloGlobal[0];
       max:= arregloGlobal[n-1];

       ubMitad:= (n-1) div 2;

       //calculo de la mediana
       if (n) mod 2 = 0 then begin
          mediana:=  (arregloGlobal[ubMitad] + arregloGlobal[ubMitad+1]) / 2.0;
       end
       else begin
         mediana:=  arregloGlobal[ubMitad];

       end;

       //se calcula q1, media de la mitad izq
       ubMitadq1:= ((n div 2)-1) div 2;

       if (n div 2)mod 2 =0 then begin
          q1:= (arregloGlobal[ubMitadq1] + arregloGlobal[ubMitadq1 + 1]) / 2.0;
       end
       else begin
         q1:= arregloGlobal[ubMitadq1];
       end;

      s:= n - (n div 2);

       if (n div 2) mod 2 = 0 then begin
          q3:= (arregloGlobal[s + ubMitadq1] + arregloGlobal[s + ubMitadq1 + 1]) / 2.0;
       end
       else begin
         q3:= arregloGlobal[s + ubMitadq1];

       end;
       //FINALMENTE GRAFICO, FAK VIEJON
       Chart1.BottomAxis.Marks.Source := nil;
       Chart1.BottomAxis.Title.Visible := True;
       Chart1.BottomAxis.Title.Caption := 'Columnas';
       Chart1.BottomAxis.Marks.Style := smsValue;
       

       Chart1.LeftAxis.Title.Visible := True;
       Chart1.LeftAxis.Title.Caption := 'Valor';

       Chart1BoxAndWhiskerSeries1.AddXY(i, min, q1, mediana, q3, max, IntToStr(i));

     end;
end;


//interaccion de elementos de la gui con funciones

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    StringGrid1.LoadFromCSVFile(OpenDialog1.FileName);

    cargarDatos(stringgrid1.RowCount, stringgrid1.ColCount);
    calMedXCol(stringgrid1.RowCount, stringgrid1.ColCount);
    calDesvXCol(stringgrid1.RowCount, stringgrid1.ColCount);


    MenuItem11.Checked:=True;
    MenuItem11.Enabled:=False;

    MenuItem5.Checked:=False;
    MenuItem5.Enabled:=True;

    MenuItem6.Checked:=False;
    MenuItem6.Enabled:=True;

    MenuItem7.Checked:=False;
    MenuItem7.Enabled:=True;

    //activamos otros botones luego de que ya hay info
    MenuItem3.Enabled:=True;
    MenuItem4.Enabled:=True;
    MenuItem12.Enabled:=True;
  end;

end;


procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.Label5Click(Sender: TObject);
begin

end;

procedure TForm1.Label6Click(Sender: TObject);
begin

end;


//BARRRRRRAS
procedure TForm1.ComboBox1Change(Sender: TObject);
var
   clases: integer;
begin

  clases:= round(dataNorm[0,ubcOLs[combobox1.itemindex]]);
  //showmessage(inttostr(clases) + ' en la ubi ' + inttostr(ubcOLs[combobox1.itemindex]));
  chart1barseries1.Clear;
  chart1barseries1.Active:=True;
  Chart1LineSeries1.Clear;
  Chart1LineSeries1.Active:=False;
  Chart1BoxAndWhiskerSeries1.Clear;
  Chart1BoxAndWhiskerSeries1.Active:=False;
  graficaBarras(round(length(dataNorm)), ubcOLs[combobox1.itemindex], clases);
end;



procedure TForm1.ComboBox2Change(Sender: TObject);
begin

end;

procedure TForm1.ComboBox3Change(Sender: TObject);
begin

end;







procedure TForm1.MenuItem3Click(Sender: TObject);
begin

end;



procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

//Clicks para normalizar
procedure TForm1.MenuItem5Click(Sender: TObject);
begin

     normZscore(stringgrid1.RowCount, stringgrid1.ColCount);
     calMedXCol(stringgrid1.RowCount, stringgrid1.ColCount);
     calDesvXCol(stringgrid1.RowCount, stringgrid1.ColCount);

     MenuItem11.Checked:=False;
     MenuItem11.Enabled:=True;

     MenuItem5.Checked:=True;
     MenuItem5.Enabled:=False;

     MenuItem6.Checked:=False;
     MenuItem6.Enabled:=True;

     MenuItem7.Checked:=False;
     MenuItem7.Enabled:=True;


end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin

  minMax(stringgrid1.RowCount, stringgrid1.ColCount);
  calMedXCol(stringgrid1.RowCount, stringgrid1.ColCount);
  calDesvXCol(stringgrid1.RowCount, stringgrid1.ColCount);

  MenuItem11.Checked:=False;
  MenuItem11.Enabled:=True;

  MenuItem5.Checked:=False;
  MenuItem5.Enabled:=True;

  MenuItem6.Checked:=True;
  MenuItem6.Enabled:=False;

  MenuItem7.Checked:=False;
  MenuItem7.Enabled:=True;

end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin

  escDecimal(stringgrid1.RowCount, stringgrid1.ColCount);
  calMedXCol(stringgrid1.RowCount, stringgrid1.ColCount);
  calDesvXCol(stringgrid1.RowCount, stringgrid1.ColCount);

  MenuItem11.Checked:=False;
  MenuItem11.Enabled:=True;

  MenuItem5.Checked:=False;
  MenuItem5.Enabled:=True;

  MenuItem6.Checked:=False;
  MenuItem6.Enabled:=True;

  MenuItem7.Checked:=True;
  MenuItem7.Enabled:=False;
end;


procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  sinNorm(stringgrid1.RowCount, stringgrid1.ColCount);
  calMedXCol(stringgrid1.RowCount, stringgrid1.ColCount);
  calDesvXCol(stringgrid1.RowCount, stringgrid1.ColCount);

  MenuItem11.Checked:=True;
  MenuItem11.Enabled:=False;

  MenuItem5.Checked:=False;
  MenuItem5.Enabled:=True;

  MenuItem6.Checked:=False;
  MenuItem6.Enabled:=True;

  MenuItem7.Checked:=False;
  MenuItem7.Enabled:=True;
end;



//inicia dispersijn
procedure TForm1.Button1Click(Sender: TObject);
begin
  if (ComboBox2.ItemIndex = -1) or (ComboBox3.ItemIndex = -1) then
  begin
       ShowMessage('Por favor, elige un atributo válido. (˶º⤙º˶)');
       Exit;//no ejecuta lo de abajo
  end;

  if ComboBox2.ItemIndex = ComboBox3.ItemIndex then
  begin
       ShowMessage('Por favor, elige dos atributos distintos. (˶º⤙º˶)');
       Exit;//no ejecuta lo de abajo
  end;

  chart1barseries1.Clear;
  chart1barseries1.Active:=False;
  Chart1BoxAndWhiskerSeries1.Clear;
  Chart1BoxAndWhiskerSeries1.Active:=False;
  Chart1LineSeries1.Active:=True;
  Chart1LineSeries1.Clear;

  graficaDisper(round(length(dataNorm)), combobox2.ItemIndex, combobox3.itemindex);



end;
//boton para inciar BOXPLOTSSS
procedure TForm1.Button2Click(Sender: TObject);
var
   clases: integer;
begin
  if combobox4.ItemIndex = -1 then
  begin
       ShowMessage('Por favor, elige un atributo válido. (˶º⤙º˶)');
       Exit;//no ejecuta lo de abajo
  end;
  clases:= round(dataNorm[0,length(dataNorm[0])-1]);
  //showmessage(inttostr(round(length(dataNorm))));

  Chart1BoxAndWhiskerSeries1.Clear;
  Chart1BoxAndWhiskerSeries1.Active:=True;
  Chart1LineSeries1.Clear;
  Chart1LineSeries1.Active:=False;
  chart1barseries1.Clear;
  chart1barseries1.Active:=False;

  graficaBoxPlot(round(length(dataNorm)), clases, combobox4.ItemIndex);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin

  Chart1BoxAndWhiskerSeries1.Clear;
  Chart1BoxAndWhiskerSeries1.Active:=True;
  Chart1LineSeries1.Clear;
  Chart1LineSeries1.Active:=False;
  chart1barseries1.Clear;
  chart1barseries1.Active:=False;
  graficaBoxPlotGeneral(round(length(dataNorm)), round(length(dataNorm[0])));
end;


//box plot
procedure TForm1.MenuItem9Click(Sender: TObject);
begin
     ComboBox4.Clear;
     ComboBox4.visible:= True;

     ComboBox1.Visible:= False;
     ComboBox2.Visible:= False;
     ComboBox3.Visible:= False;
     Button1.Visible:=False;

     MenuItem8.Checked:=False;
     MenuItem9.Checked:=True;
     MenuItem10.Checked:=False;
     label4.Caption:='BoxPlot:';
     Button2.Visible:=True;
     Button3.Visible:=True;

     Chart1BoxAndWhiskerSeries1.Clear;
     Chart1BoxAndWhiskerSeries1.Active:=True;
     Chart1LineSeries1.Clear;
     Chart1LineSeries1.Active:=False;
     chart1barseries1.Clear;
     chart1barseries1.Active:=False;

     listaBP();
end;

//Dispersión
procedure TForm1.MenuItem8Click(Sender: TObject);
begin

       ComboBox1.visible:= false;
       MenuItem8.Checked:=True;
       MenuItem9.Checked:=False;
       MenuItem10.Checked:=False;

       chart1barseries1.Clear;
       chart1barseries1.Active:=False;
       Chart1BoxAndWhiskerSeries1.Clear;
       Chart1BoxAndWhiskerSeries1.Active:=False;
       Chart1LineSeries1.Active:=True;
       Chart1LineSeries1.Clear;

       ComboBox2.Clear;
       ComboBox3.clear;

       ComboBox4.visible:= false;

       Button2.Visible:= False;
       Button3.Visible:=False;

       label4.Caption:='Dispersión:';
       listaXYparaDisp();
end;

//BARRAS
procedure TForm1.MenuItem10Click(Sender: TObject);
var
   j,k, index: integer;

begin

  MenuItem8.Checked:=False;
  MenuItem9.Checked:=False;
  MenuItem10.Checked:=True;
  ComboBox1.Visible:= True;
  ComboBox2.Visible:= False;
  ComboBox3.Visible:= False;
  ComboBox4.visible:= false;
  Button1.Visible:=False;
  Button2.Visible:= False;
  Button3.Visible:=False;

  chart1barseries1.Clear;
  chart1barseries1.Active:=True;
  Chart1LineSeries1.Clear;
  Chart1LineSeries1.Active:=False;
  Chart1BoxAndWhiskerSeries1.Clear;
  Chart1BoxAndWhiskerSeries1.Active:=False;

  //showmessage(floattostr(dataset[0,stringgrid1.ColCount+1]));
  ubcols := nil;//quitar adv
  setlength(ubcols, 0);
  k:=0;
  index:=-1;
  combobox1.Items.Clear;
  label4.Caption:='Barras:';

  for j:=0 to stringgrid1.ColCount do begin
      //gracioso porque ahora saltamos numericos
      index:=index+1;
      if dataNorm[0,j] = 0 then begin
           continue;
      end;

      setLength(ubCols, Length(ubcols) + 1);
      ubCols[k]:= index;
      k:=k+1;
      //clases:= round(dataset[0,j]);
      combobox1.items.add('Atributo: ' + inttostr(k) {+' Clases'+ inttostr(clases)});
      //combobox1.items.add('Col j: ' + inttostr(ubCols[k-1]));
  end;

end;

//Guardar archivo del string grid
procedure TForm1.MenuItem12Click(Sender: TObject);
var
   i: integer;
begin
  if savedialog1.Execute then begin
    AssignFile(F,Savedialog1.FileName);

    {$I-}
         rewrite(F);  //crear archivo...si existe Sobre escribe y destruye
    {$I+}

    if IOResult=0 then
    begin

      for i:= 0 to stringgrid1.RowCount-1 do begin

        Writeln(F,stringgrid1.Rows[i].CommaText);

      end;
      closefile(F);
    end;
  end;
end;

end.

